#!/usr/bin/env python3
"""Report which characters an .xpr bitmap font covers, and diff that against
the achievement strings extracted from the XEX.

The XPR "FontData" blob is the stock XDK/ATG bitmap-font layout:

    0x80  DWORD  version (5)
    0x84  FLOAT  font height
    0x94  WORD   max mapped codepoint (0x2122 for font_en, 0xFF1A for font_ja)
    0x96  WORD[] translator table, indexed by UTF-16 codepoint;
                 entry is a glyph index, 0 means "no glyph"

The achievement text has to be extracted first (writes achievements.toml plus
the icons into the given directory):

    sdk/bin/rexglue.exe init --project-name NocturneRecomp \
        --xex-path assets/default.xex \
        achievements assets/default.xex build/ach_ja --language 2

Then:

    python scripts/font_coverage.py --achievements build/ach_ja/achievements.toml
    python scripts/font_coverage.py --list             # dump every covered char

Rerun this after any change to the set of strings drawn with the game's own
font, and feed the missing list into scripts/gen-glyphs.py's
REQUIRED_CODEPOINTS.
"""
import argparse
import os
import re
import struct
import sys
import unicodedata

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

TABLE_OFF = 0x96
MAXCP_OFF = 0x94
VERSION_OFF = 0x80
HEIGHT_OFF = 0x84

TEXT_KEYS = ("label", "description", "unachieved_description")
_TEXT_RE = re.compile(r'\s*(%s)\s*=\s*"(.*)"\s*$' % "|".join(TEXT_KEYS))


def load_font(path):
    """Return (version, height, {codepoint: glyph_index})."""
    with open(path, "rb") as f:
        data = f.read()
    version, = struct.unpack_from(">I", data, VERSION_OFF)
    height, = struct.unpack_from(">f", data, HEIGHT_OFF)
    max_cp, = struct.unpack_from(">H", data, MAXCP_OFF)
    table = {}
    for cp in range(max_cp + 1):
        glyph, = struct.unpack_from(">H", data, TABLE_OFF + cp * 2)
        if glyph:
            table[cp] = glyph
    return version, height, table


def load_achievement_chars(path):
    """Return {char: [contexts]} for every char in the achievement strings."""
    used = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = _TEXT_RE.match(line)
            if not m:
                continue
            # TOML basic strings: unescape the sequences rexglue emits.
            text = m.group(2).replace("\\r", "").replace("\\n", "").replace('\\"', '"')
            text = text.replace("\\\\", "\\")
            for ch in text:
                used.setdefault(ch, []).append(m.group(1))
    return used


def describe(ch):
    return "U+%04X  %s   %s" % (ord(ch), ch, unicodedata.name(ch, "<unnamed>"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--font", default=os.path.join(ROOT, "assets", "MEDIA", "font_ja.xpr"))
    ap.add_argument("--achievements",
                    default=os.path.join(ROOT, "build", "ach_ja", "achievements.toml"),
                    help="achievements.toml from `rexglue init achievements` (see above)")
    ap.add_argument("--list", action="store_true", help="dump every covered codepoint")
    args = ap.parse_args()

    sys.stdout.reconfigure(encoding="utf-8")

    version, height, table = load_font(args.font)
    print("font:   %s" % os.path.relpath(args.font, ROOT))
    print("  version %d, height %g, %d glyphs, max codepoint U+%04X"
          % (version, height, len(table), max(table)))

    if args.list:
        for cp in sorted(table):
            print("  %s -> glyph %d" % (describe(chr(cp)), table[cp]))
        return

    used = load_achievement_chars(args.achievements)
    printable = {ch: ctx for ch, ctx in used.items() if ord(ch) > 0x1F}
    missing = sorted((ch for ch in printable if ord(ch) not in table), key=ord)

    print("\nachievements: %s" % os.path.relpath(args.achievements, ROOT))
    print("  %d distinct printable characters" % len(printable))
    print("\nMISSING FROM FONT (%d):" % len(missing))
    for ch in missing:
        print("  %s" % describe(ch))


if __name__ == "__main__":
    main()
