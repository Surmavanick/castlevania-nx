# Nintendo Switch build of NocturneRecomp (NRO). Included from CMakeLists.txt
# when REXGLUE_PLATFORM_SWITCH is set by the devkitA64 toolchain file.

option(NOCTURNE_TU "Build for a baked-in title update" OFF)

# Generated (recompiled) code: its own object library, so its flags stay
# separate from the app's.
add_library(nocturnerecomp_recomp OBJECT ${GENERATED_SOURCES})
target_include_directories(nocturnerecomp_recomp PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/generated)
target_link_libraries(nocturnerecomp_recomp PRIVATE rex::runtime)
target_compile_features(nocturnerecomp_recomp PRIVATE cxx_std_23)
# This pinned (0.9-era) code generator emits one combined init header rather
# than the newer nocturnerecomp_pch.h/init.h split. Every generated translation
# unit includes it first, so use the existing combined header as the PCH.
target_precompile_headers(nocturnerecomp_recomp PRIVATE
    "${CMAKE_SOURCE_DIR}/generated/nocturnerecomp_init.h")
# project8-sw: GCC merged pairs of guest-context copies into q-register moves,
# and a page fault between them came back with q31 cleared on Horizon.
target_compile_options(nocturnerecomp_recomp PRIVATE
    -fno-tree-slp-vectorize -fno-tree-vectorize -Wno-unused-label -Wno-unused-variable)

list(REMOVE_ITEM NOCTURNERECOMP_SOURCES ${GENERATED_SOURCES})
add_executable(nocturnerecomp ${NOCTURNERECOMP_SOURCES})
target_include_directories(nocturnerecomp PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/generated
    "${REXSDK_DIR}/thirdparty/imgui"
    # Keep parity with the project8 native-renderer target. This directory owns
    # SDK-private prebuilt shader headers used by native presentation paths.
    "${REXSDK_DIR}/src/graphics"
    "${REXSDK_DIR}/thirdparty/glslang")
target_link_libraries(nocturnerecomp PRIVATE nocturnerecomp_recomp)
rexglue_switch_configure_target(nocturnerecomp)
target_link_libraries(nocturnerecomp PRIVATE rex::gpu-shader-translation xxHash::xxhash)
if(NOCTURNE_TU)
    target_compile_definitions(nocturnerecomp PRIVATE NOCTURNE_TU=1)
endif()

set(_nocturne_icon "${CMAKE_SOURCE_DIR}/switch/icon-public.jpg")
if(NOT EXISTS "${_nocturne_icon}")
    set(_nocturne_icon "")
endif()
rexglue_switch_add_nro(nocturnerecomp
    NAME "Castlevania: Symphony of the Night"
    AUTHOR "NocturneRecomp (Switch build)"
    VERSION "${NOCTURNE_VERSION}"
    ICON "${_nocturne_icon}")
