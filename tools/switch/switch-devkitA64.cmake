# Nintendo Switch / libnx cross toolchain for the static ReXGlue runtime.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(REXGLUE_PLATFORM_SWITCH ON CACHE BOOL "Horizon target" FORCE)
set(REXGLUE_USE_VULKAN ON CACHE BOOL "Static NVK renderer" FORCE)
set(REXGLUE_USE_D3D12 OFF CACHE BOOL "No D3D12 on Horizon" FORCE)
set(REXGLUE_ENABLE_TRACY OFF CACHE BOOL "No Tracy on Horizon" FORCE)
set(REXGLUE_ENABLE_PERF_COUNTERS ON CACHE BOOL "Switch performance counters" FORCE)

if(DEFINED ENV{DEVKITPRO})
    set(SWITCH_DEVKITPRO "$ENV{DEVKITPRO}")
else()
    set(SWITCH_DEVKITPRO "/opt/devkitpro")
endif()
set(DEVKITPRO "${SWITCH_DEVKITPRO}" CACHE PATH "devkitPro root")
set(SWITCH_TOOL_PREFIX "${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-")

set(CMAKE_C_COMPILER "${SWITCH_TOOL_PREFIX}gcc")
set(CMAKE_CXX_COMPILER "${SWITCH_TOOL_PREFIX}g++")
set(CMAKE_ASM_COMPILER "${SWITCH_TOOL_PREFIX}gcc")
set(CMAKE_AR "${SWITCH_TOOL_PREFIX}gcc-ar" CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB "${SWITCH_TOOL_PREFIX}gcc-ranlib" CACHE FILEPATH "" FORCE)
set(CMAKE_NM "${SWITCH_TOOL_PREFIX}nm" CACHE FILEPATH "" FORCE)
set(CMAKE_OBJCOPY "${SWITCH_TOOL_PREFIX}objcopy" CACHE FILEPATH "" FORCE)
set(CMAKE_STRIP "${SWITCH_TOOL_PREFIX}strip" CACHE FILEPATH "" FORCE)
set(CMAKE_C_COMPILER_AR "${CMAKE_AR}")
set(CMAKE_C_COMPILER_RANLIB "${CMAKE_RANLIB}")
set(CMAKE_CXX_COMPILER_AR "${CMAKE_AR}")
set(CMAKE_CXX_COMPILER_RANLIB "${CMAKE_RANLIB}")

set(SWITCH_ARCH_FLAGS "-march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft")
set(SWITCH_DEFINES "-D__SWITCH__ -DNX -D_GNU_SOURCE -DSPDLOG_NO_TZ_OFFSET")
set(SWITCH_COMMON_FLAGS "${SWITCH_ARCH_FLAGS} ${SWITCH_DEFINES} -fPIE -ftls-model=local-exec")
set(CMAKE_C_FLAGS_INIT "${SWITCH_COMMON_FLAGS} -ffunction-sections -fdata-sections -Wno-psabi")
set(CMAKE_CXX_FLAGS_INIT "${SWITCH_COMMON_FLAGS} -ffunction-sections -fdata-sections -Wno-psabi")
set(CMAKE_ASM_FLAGS_INIT "${SWITCH_COMMON_FLAGS}")

set(SWITCH_SPECS_SOURCE "${DEVKITPRO}/libnx/switch.specs")
if(NOT EXISTS "${SWITCH_SPECS_SOURCE}")
    message(FATAL_ERROR "Missing libnx linker specs: ${SWITCH_SPECS_SOURCE}")
endif()
file(READ "${SWITCH_SPECS_SOURCE}" SWITCH_SPECS_TEXT)
string(REPLACE "%:getenv(DEVKITPRO /libnx/switch.ld)"
    "${DEVKITPRO}/libnx/switch.ld" SWITCH_SPECS_TEXT "${SWITCH_SPECS_TEXT}")
file(WRITE "${CMAKE_BINARY_DIR}/switch.specs" "${SWITCH_SPECS_TEXT}")
set(CMAKE_EXE_LINKER_FLAGS_INIT
    "-specs=${CMAKE_BINARY_DIR}/switch.specs -Wl,--gc-sections -Wl,--allow-multiple-definition -Wl,--no-relax")
set(CMAKE_DL_LIBS "")

include_directories(SYSTEM
    "${DEVKITPRO}/devkitA64/include"
    "${DEVKITPRO}/libnx/include"
    "${DEVKITPRO}/portlibs/switch/include")
link_directories(
    "${DEVKITPRO}/devkitA64/lib"
    "${DEVKITPRO}/libnx/lib"
    "${DEVKITPRO}/portlibs/switch/lib")
set(CMAKE_FIND_ROOT_PATH
    "${DEVKITPRO}/devkitA64"
    "${DEVKITPRO}/libnx"
    "${DEVKITPRO}/portlibs/switch")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
