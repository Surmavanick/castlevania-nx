#include "font_overlay.h"

#include <algorithm>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <memory>
#include <string>
#include <vector>

#include <rex/filesystem.h>
#include <rex/filesystem/device.h>
#include <rex/filesystem/devices/host_path_entry.h>
#include <rex/filesystem/entry.h>
#include <rex/filesystem/file.h>
#include <rex/filesystem/vfs.h>
#include <rex/logging.h>
#include <rex/runtime.h>

#include "font_patch.h"
#include "glyph_pack.generated.h"

namespace nocturne {
namespace {

// The X_STATUS_* macros cast to a bare X_STATUS, which only names a type
// inside rex; the VFS interfaces we override spell it the same way.
using rex::X_STATUS;

constexpr const char* kGuestFontPath = "game:\\MEDIA\\font_ja.xpr";
constexpr const char* kFontFileName = "font_ja.xpr";
constexpr const char* kOverlayMount = "\\Device\\NocturneMediaOverlay";

// Serves a byte buffer we own.
class MemoryFile : public rex::filesystem::File {
 public:
  MemoryFile(uint32_t access, rex::filesystem::Entry* entry, const std::vector<uint8_t>* data)
      : File(access, entry), data_(data) {}

  void Destroy() override { delete this; }

  X_STATUS ReadSync(std::span<uint8_t> buffer, size_t byte_offset,
                    size_t* out_bytes_read) override {
    if (byte_offset >= data_->size()) {
      *out_bytes_read = 0;
      return X_STATUS_END_OF_FILE;
    }
    const size_t count = std::min(buffer.size(), data_->size() - byte_offset);
    std::memcpy(buffer.data(), data_->data() + byte_offset, count);
    *out_bytes_read = count;
    return X_STATUS_SUCCESS;
  }

  X_STATUS WriteSync(std::span<const uint8_t>, size_t, size_t* out_bytes_written) override {
    *out_bytes_written = 0;
    return X_STATUS_ACCESS_DENIED;
  }

 private:
  const std::vector<uint8_t>* data_;
};

// Serves a real file on the host, so every sibling in MEDIA that we are not
// replacing behaves exactly as it did before the shadow was installed.
class HostFile : public rex::filesystem::File {
 public:
  HostFile(uint32_t access, rex::filesystem::Entry* entry, const std::filesystem::path& path)
      : File(access, entry), stream_(path, std::ios::binary) {}

  void Destroy() override { delete this; }

  X_STATUS ReadSync(std::span<uint8_t> buffer, size_t byte_offset,
                    size_t* out_bytes_read) override {
    *out_bytes_read = 0;
    if (!stream_) {
      return X_STATUS_UNSUCCESSFUL;
    }
    stream_.clear();
    stream_.seekg(static_cast<std::streamoff>(byte_offset), std::ios::beg);
    if (!stream_) {
      return X_STATUS_END_OF_FILE;
    }
    stream_.read(reinterpret_cast<char*>(buffer.data()),
                 static_cast<std::streamsize>(buffer.size()));
    const size_t count = static_cast<size_t>(stream_.gcount());
    *out_bytes_read = count;
    return count ? X_STATUS_SUCCESS : X_STATUS_END_OF_FILE;
  }

  X_STATUS WriteSync(std::span<const uint8_t>, size_t, size_t* out_bytes_written) override {
    *out_bytes_written = 0;
    return X_STATUS_ACCESS_DENIED;
  }

 private:
  std::ifstream stream_;
};

class MemoryEntry : public rex::filesystem::Entry {
 public:
  MemoryEntry(rex::filesystem::Device* device, rex::filesystem::Entry* parent,
              const std::string& path, std::vector<uint8_t> data)
      : Entry(device, parent, path), data_(std::move(data)) {
    attributes_ = rex::filesystem::kFileAttributeReadOnly;
    size_ = data_.size();
    allocation_size_ = data_.size();
  }

  X_STATUS Open(uint32_t desired_access, rex::filesystem::File** out_file) override {
    *out_file = new MemoryFile(desired_access, this, &data_);
    return X_STATUS_SUCCESS;
  }

 private:
  std::vector<uint8_t> data_;
};

class HostEntry : public rex::filesystem::Entry {
 public:
  HostEntry(rex::filesystem::Device* device, rex::filesystem::Entry* parent,
            const std::string& path, std::filesystem::path host_path, size_t size)
      : Entry(device, parent, path), host_path_(std::move(host_path)) {
    attributes_ = rex::filesystem::kFileAttributeReadOnly;
    size_ = size;
    allocation_size_ = size;
  }

  X_STATUS Open(uint32_t desired_access, rex::filesystem::File** out_file) override {
    *out_file = new HostFile(desired_access, this, host_path_);
    return X_STATUS_SUCCESS;
  }

 private:
  std::filesystem::path host_path_;
};

// The shadow MEDIA directory. Its children are the real directory's files,
// with font_ja.xpr swapped for the composed image.
//
// This has to shadow the whole directory rather than just the one file,
// because VirtualFileSystem::OpenFile resolves only the *parent* path through
// ResolvePath (which honours symlinks) and then looks the filename up with
// Entry::GetChild, which does not. A symlink on the full file path is
// therefore never consulted on the open path -- only a directory-level shadow
// puts our entry where GetChild will find it.
class MediaDirEntry : public rex::filesystem::Entry {
 public:
  MediaDirEntry(rex::filesystem::Device* device, const std::string& path)
      : Entry(device, nullptr, path) {
    attributes_ = rex::filesystem::kFileAttributeDirectory;
  }

  X_STATUS Open(uint32_t, rex::filesystem::File**) override { return X_STATUS_ACCESS_DENIED; }

  void Add(std::unique_ptr<rex::filesystem::Entry> child) {
    children_.push_back(std::move(child));
  }
};

class MediaOverlayDevice : public rex::filesystem::Device {
 public:
  explicit MediaOverlayDevice(const std::string& mount_path)
      : Device(mount_path), name_("NocturneMediaOverlay") {
    root_ = std::make_unique<MediaDirEntry>(this, "");
  }

  bool Initialize() override { return true; }
  void Dump(rex::string::StringBuffer*) override {}

  rex::filesystem::Entry* ResolvePath(const std::string_view path) override {
    // An empty path is the documented alias for the device root.
    return path.empty() ? root_.get() : root_->ResolvePath(path);
  }

  MediaDirEntry* root() { return root_.get(); }

  const std::string& name() const override { return name_; }
  uint32_t attributes() const override { return 0; }
  uint32_t component_name_max_length() const override { return 255; }
  uint32_t total_allocation_units() const override { return 128 * 1024; }
  uint32_t available_allocation_units() const override { return 0; }
  uint32_t sectors_per_allocation_unit() const override { return 1; }
  uint32_t bytes_per_sector() const override { return 0x200; }

 private:
  std::string name_;
  std::unique_ptr<MediaDirEntry> root_;
};

}  // namespace

unsigned InstallJapaneseFontOverlay(rex::Runtime* runtime) {
  if (!runtime) {
    return 0;
  }
  auto* vfs = runtime->file_system();
  if (!vfs) {
    return 0;
  }

  rex::filesystem::Entry* font_entry = vfs->ResolvePath(kGuestFontPath);
  if (!font_entry) {
    REXLOG_DEBUG("font overlay: no {} to patch", kGuestFontPath);
    return 0;
  }

  // We need the real host directory to mirror. Only a host-backed game mount
  // can be shadowed this way; a disc image or STFS container has no directory
  // on disk to enumerate, so leave those alone.
  const auto* host_entry = dynamic_cast<const rex::filesystem::HostPathEntry*>(font_entry);
  if (!host_entry) {
    REXLOG_DEBUG("font overlay: game data is not a host directory, skipping");
    return 0;
  }
  const std::filesystem::path font_host_path = host_entry->host_path();
  const std::filesystem::path media_dir = font_host_path.parent_path();

  rex::filesystem::Entry* media_entry = font_entry->parent();
  if (!media_entry) {
    REXLOG_DEBUG("font overlay: font has no parent directory entry, skipping");
    return 0;
  }
  const std::string media_device_path = media_entry->absolute_path();

  std::vector<uint8_t> original;
  {
    std::ifstream in(font_host_path, std::ios::binary | std::ios::ate);
    if (!in) {
      REXLOG_DEBUG("font overlay: cannot read {}", font_host_path.string());
      return 0;
    }
    original.resize(static_cast<size_t>(in.tellg()));
    in.seekg(0);
    in.read(reinterpret_cast<char*>(original.data()),
            static_cast<std::streamsize>(original.size()));
  }

  FontPatchResult patched = PatchFont(original, kSupplementalGlyphs);
  if (patched.out_of_space) {
    REXLOG_WARN("font overlay: ran out of atlas space; some glyphs were dropped");
  }
  if (patched.image.empty()) {
    REXLOG_DEBUG("font overlay: not patching font_ja.xpr ({})",
                 patched.error ? patched.error : "unknown");
    return 0;
  }
  const size_t patched_size = patched.image.size();

  auto device = std::make_unique<MediaOverlayDevice>(kOverlayMount);
  MediaOverlayDevice* device_raw = device.get();
  MediaDirEntry* root = device_raw->root();

  // Mirror every sibling so nothing else in MEDIA changes behaviour, then
  // substitute the composed font.
  size_t mirrored = 0;
  std::error_code ec;
  for (const auto& item : std::filesystem::directory_iterator(media_dir, ec)) {
    if (ec) {
      break;
    }
    if (!item.is_regular_file()) {
      // MEDIA is flat in every layout we have seen; a subdirectory would need
      // recursive mirroring, so bail rather than silently hide it.
      REXLOG_WARN("font overlay: {} contains a subdirectory, not shadowing",
                  media_dir.string());
      return 0;
    }
    const std::string name = item.path().filename().string();
    if (rex::string::utf8_equal_case(name, kFontFileName)) {
      continue;
    }
    root->Add(std::make_unique<HostEntry>(device_raw, root, name, item.path(),
                                          static_cast<size_t>(item.file_size(ec))));
    ++mirrored;
  }
  if (ec || mirrored == 0) {
    REXLOG_WARN("font overlay: could not enumerate {}, not shadowing", media_dir.string());
    return 0;
  }
  root->Add(std::make_unique<MemoryEntry>(device_raw, root, kFontFileName,
                                          std::move(patched.image)));

  if (!vfs->RegisterDevice(std::move(device))) {
    REXLOG_WARN("font overlay: could not register the overlay device");
    return 0;
  }
  // Shadow the directory, not the file -- see MediaDirEntry.
  if (!vfs->RegisterSymbolicLink(media_device_path, kOverlayMount)) {
    REXLOG_WARN("font overlay: could not register the overlay symlink");
    vfs->UnregisterDevice(kOverlayMount);
    return 0;
  }

  // Verify through the same two-step the open path actually uses: resolve the
  // parent, then GetChild the filename. Resolving the full path would only
  // prove the symlink exists, which is what the previous attempt got wrong.
  rex::filesystem::Entry* parent = vfs->ResolvePath("d:\\media");
  rex::filesystem::Entry* child = parent ? parent->GetChild(kFontFileName) : nullptr;
  if (!child) {
    REXLOG_WARN("font overlay: 'd:\\media' + GetChild({}) does not resolve", kFontFileName);
  } else if (child->size() != patched_size) {
    REXLOG_WARN("font overlay: open path still yields the unpatched font ({} bytes, "
                "expected {})", child->size(), patched_size);
  } else {
    REXLOG_INFO("font overlay: open path yields the composed font ({} bytes), "
                "{} sibling(s) mirrored", child->size(), mirrored);
  }

  REXLOG_INFO("font overlay: added {} supplemental glyph(s) to font_ja.xpr, aliased {} fullwidth",
              patched.glyphs_added, patched.glyphs_aliased);
  return patched.glyphs_added;
}

}  // namespace nocturne
