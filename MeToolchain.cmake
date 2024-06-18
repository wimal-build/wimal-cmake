cmake_minimum_required(VERSION 3.10)

function(me_install_toolchain)
    set(CACHE_DIR "${CMAKE_CURRENT_LIST_DIR}/.cache")
    # Remove cache directory if exists.
    if(EXISTS "${CACHE_DIR}")
        message(STATUS "Removing ${CACHE_DIR}")
        file(REMOVE_RECURSE "${CACHE_DIR}")
    endif()
    # Create cache directory.
    message(STATUS "Creating ${CACHE_DIR}")
    file(MAKE_DIRECTORY "${CACHE_DIR}")
    message(STATUS "Host: ${CMAKE_HOST_SYSTEM_NAME}")
    # Fetch latest release.
    set(RELEASE_URL https://github.com/wimal-build/wimal/releases)
    set(API_URL https://api.github.com/repos/wimal-build/wimal)
    message(STATUS "Fetching ${API_URL}/releases/latest")
    file(DOWNLOAD ${API_URL}/releases/latest ${CACHE_DIR}/releases)
    file(READ "${CACHE_DIR}/releases" releases)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
        set(system linux)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
        set(system macos)
    endif()
    # Parse the latest version and filenames.
    if(releases MATCHES "/download/([^/]+)/(wimal-${system}[^\"]*.tar.xz)")
        set(wimal-version ${CMAKE_MATCH_1})
        set(wimal-toolchain ${CMAKE_MATCH_2})
        message(STATUS "Latest version: ${wimal-version}")
        message(STATUS "Toolchain: ${wimal-toolchain}")
    else()
        message(FATAL_ERROR "No releases found: ${releases}")
        exit()
    endif()
    if(releases MATCHES "/download/${wimal-version}/(wimal-compiler-rt[^\"]*.tar.xz)")
        set(wimal-compiler-rt ${CMAKE_MATCH_1})
    else()
        message(FATAL_ERROR "No releases found: ${releases}")
    endif()
    message(STATUS "Compiler-rt: ${wimal-compiler-rt}")
    if(releases MATCHES "/download/${wimal-version}/(wimal-sysroot[^\"]*.tar.xz)")
        set(wimal-sysroot ${CMAKE_MATCH_1})
    else()
        message(FATAL_ERROR "No releases found: ${releases}")
    endif()
    message(STATUS "Sysroot: ${wimal-sysroot}")
    # Download the toolchain tarball.
    set(url "${RELEASE_URL}/download/${wimal-version}/${wimal-toolchain}")
    message(STATUS "Downloading: ${url}")
    file(DOWNLOAD "${url}" "${CACHE_DIR}/toolchain.tar.xz" SHOW_PROGRESS STATUS status)
    list(GET status 0 error)
    list(GET status 1 message)
    if(error)
        message(FATAL_ERROR "Failed to download, error=${error} message=${message}")
    endif()
    # Download the compiler-rt tarball.
    set(url "${RELEASE_URL}/download/${wimal-version}/${wimal-compiler-rt}")
    message(STATUS "Downloading: ${url}")
    file(DOWNLOAD "${url}" "${CACHE_DIR}/compiler-rt.tar.xz" SHOW_PROGRESS STATUS status)
    list(GET status 0 error)
    list(GET status 1 message)
    if(error)
        message(FATAL_ERROR "Failed to download, error=${error} message=${message}")
    endif()
    # Download the sysroot tarball.
    set(url "${RELEASE_URL}/download/${wimal-version}/${wimal-sysroot}")
    message(STATUS "Downloading: ${url}")
    file(DOWNLOAD "${url}" "${CACHE_DIR}/sysroot.tar.xz" SHOW_PROGRESS STATUS status)
    list(GET status 0 error)
    list(GET status 1 message)
    if(error)
        message(FATAL_ERROR "Failed to download, error=${error} message=${message}")
    endif()
    # Clean old wimal installation.
    set(WIMAL_DIR "${CMAKE_CURRENT_LIST_DIR}/wimal")
    if(EXISTS "${WIMAL_DIR}")
        message(STATUS "Removing ${WIMAL_DIR}")
        file(REMOVE_RECURSE "${WIMAL_DIR}")
    endif()
    # Extract toolchain.
    message(STATUS "Extracting ${CACHE_DIR}/toolchain.tar.xz")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar Jxf "${CACHE_DIR}/toolchain.tar.xz"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
        RESULT_VARIABLE error
    )
    if(error)
        message(FATAL_ERROR "Failed to extract ${CACHE_DIR}/toolchain.tar.xz")
    endif()
    # Extract compiler-rt.
    message(STATUS "Extracting ${CACHE_DIR}/compiler-rt.tar.xz")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar Jxf "${CACHE_DIR}/compiler-rt.tar.xz"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
        RESULT_VARIABLE error
    )
    if(error)
        message(FATAL_ERROR "Failed to extract ${CACHE_DIR}/compiler-rt.tar.xz")
    endif()
    # Extract toolchain.
    message(STATUS "Extracting ${CACHE_DIR}/sysroot.tar.xz")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar Jxf "${CACHE_DIR}/sysroot.tar.xz"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/wimal"
        RESULT_VARIABLE error
    )
    if(error)
        message(FATAL_ERROR "Failed to extract ${CACHE_DIR}/toolchain.tar.xz")
    endif()
    # Cleanup cache directory.
    file(REMOVE_RECURSE "${CACHE_DIR}")
    # Install wimal.
    message(STATUS "Installing wimal")
    execute_process(
        COMMAND "${CMAKE_CURRENT_LIST_DIR}/wimal/bin/wimal" install
        RESULT_VARIABLE error
    )
    if(error)
        message(FATAL_ERROR "Failed to install wimal")
    endif()
endfunction(me_install_toolchain)

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
    me_install_toolchain()
    return()
endif()

if(NOT WIMAL_HOME)
    set(WIMAL_HOME $ENV{WIMAL_HOME})
endif()

if(NOT WIMAL_HOME)
    set(WIMAL_HOME "${CMAKE_CURRENT_LIST_DIR}/wimal")
endif()

if(NOT EXISTS "${WIMAL_HOME}/bin/wimal")
    if(EXISTS "/wimal/bin/wimal")
        set(WIMAL_HOME "/wimal")
    else(DEFINED ENV{WIMAL_HOME})
        message(STATUS "wimal not found, installing")
        me_install_toolchain()
    endif()
endif()

if(NOT EXISTS "${WIMAL_HOME}/bin/wimal")
    message(FATAL_ERROR "wimal not found in ${WIMAL_HOME}/bin/wimal")
endif()

if(NOT WIMAL_TARGET)
    set(WIMAL_TARGET x64-linux)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
        set(WIMAL_TARGET x64-macos)
    endif()
endif()

set(WIMAL_HOME "${WIMAL_HOME}" CACHE PATH WIMAL_HOME)
set(CMAKE_C_COMPILER "${WIMAL_HOME}/bin/${WIMAL_TARGET}-cc" CACHE PATH CMAKE_C_COMPILER)
set(CMAKE_CXX_COMPILER "${WIMAL_HOME}/bin/${WIMAL_TARGET}-c++" CACHE PATH CMAKE_CXX_COMPILER)

set(CMAKE_AR "${WIMAL_HOME}/bin/${WIMAL_TARGET}-ar" CACHE PATH CMAKE_AR)
set(CMAKE_NM "${WIMAL_HOME}/bin/${WIMAL_TARGET}-nm" CACHE PATH CMAKE_NM)
set(CMAKE_RANLIB "${WIMAL_HOME}/bin/${WIMAL_TARGET}-ranlib" CACHE PATH CMAKE_RANLIB)
set(CMAKE_OBJCOPY "${WIMAL_HOME}/bin/${WIMAL_TARGET}-objcopy" CACHE PATH CMAKE_OBJCOPY)
set(CMAKE_OBJDUMP "${WIMAL_HOME}/bin/${WIMAL_TARGET}-objdump" CACHE PATH CMAKE_OBJDUMP)
set(CMAKE_STRIP "${WIMAL_HOME}/bin/${WIMAL_TARGET}-strip" CACHE PATH CMAKE_STRIP)
set(CMAKE_DSYMUTIL "${WIMAL_HOME}/bin/${WIMAL_TARGET}-dsymutil" CACHE PATH CMAKE_DSYMUTIL)
set(
    CMAKE_INSTALL_NAME_TOOL
    "${WIMAL_HOME}/bin/${WIMAL_TARGET}-install_name_tool"
    CACHE PATH CMAKE_INSTALL_NAME_TOOL
)
set(CMAKE_C_COMPILER_AR "${CMAKE_AR}" CACHE PATH CMAKE_C_COMPILER_AR)
set(CMAKE_CXX_COMPILER_AR "${CMAKE_AR}" CACHE PATH CMAKE_CXX_COMPILER_AR)
set(CMAKE_C_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE PATH CMAKE_C_COMPILER_RANLIB)
set(CMAKE_CXX_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE PATH CMAKE_CXX_COMPILER_RANLIB)
set(CMAKE_CROSSCOMPILING ON CACHE BOOL CMAKE_CROSSCOMPILING)

if(WIMAL_TARGET MATCHES "-macos" OR WIMAL_TARGET MATCHES "-ios")
    set(CMAKE_SYSTEM_NAME Darwin CACHE STRING CMAKE_SYSTEM_NAME)
else()
    set(CMAKE_SYSTEM_NAME Linux CACHE STRING CMAKE_SYSTEM_NAME)
endif()

set(ME_SYSROOT "${WIMAL_HOME}/sysroot/${WIMAL_TARGET}" CACHE PATH ME_SYSROOT)
set(CMAKE_OSX_SYSROOT "${ME_SYSROOT}" CACHE PATH CMAKE_OSX_SYSROOT)
set(CMAKE_FIND_ROOT_PATH "${ME_SYSROOT}" CACHE PATH CMAKE_FIND_ROOT_PATH)
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE BOOL CMAKE_BUILD_WITH_INSTALL_RPATH)

# When a darwin shared library is linked with the `-exported_symbols_list` flag, all unlisted
# symbols will be treated as if they were marked as visibility=hidden.
# See: https://www.unix.com/man-page/osx/1/ld/
if(WIMAL_TARGET MATCHES "-android")
    set(EXTRA_CFLAGS "-fvisibility=hidden")
elseif(WIMAL_TARGET MATCHES "-macos")
    set(CMAKE_SYSTEM_VERSION "10.10" CACHE STRING CMAKE_SYSTEM_VERSION)
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# https://github.com/ninja-build/ninja/wiki/FAQ
set(CMAKE_C_FLAGS "${EXTRA_CFLAGS} -fcolor-diagnostics -fPIC -pipe" CACHE STRING CMAKE_C_FLAGS)
set(CMAKE_C_FLAGS_DEBUG "-O0 -g -fstandalone-debug -fno-limit-debug-info" CACHE STRING CMAKE_C_FLAGS_DEBUG)
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG" CACHE STRING CMAKE_C_FLAGS_RELEASE)
set(
    CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g -DNDEBUG"
    CACHE STRING CMAKE_C_FLAGS_RELWITHDEBINFO
)
set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG" CACHE STRING CMAKE_C_FLAGS_MINSIZEREL)

set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING CMAKE_CXX_FLAGS)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING CMAKE_CXX_FLAGS_DEBUG)
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING CMAKE_CXX_FLAGS_RELEASE)
set(
    CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}"
    CACHE STRING CMAKE_CXX_FLAGS_RELWITHDEBINFO
)
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}" CACHE STRING CMAKE_C_FLAGS)

if(WIMAL_TARGET MATCHES -android)
    set(CMAKE_EXE_LINKER_FLAGS "-pie")
endif()

# Suppress warnings
set(CMAKE_POLICY_DEFAULT_CMP0068 NEW CACHE STRING CMAKE_POLICY_DEFAULT_CMP0068)
set(CMAKE_POLICY_DEFAULT_CMP0069 NEW CACHE STRING CMAKE_POLICY_DEFAULT_CMP0069)
if(NOT WIMAL_TARGET MATCHES "-macos" AND NOT WIMAL_TARGET MATCHES "-ios")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON CACHE BOOL CMAKE_INTERPROCEDURAL_OPTIMIZATION)
endif()
