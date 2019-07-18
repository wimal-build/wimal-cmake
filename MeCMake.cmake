cmake_minimum_required(VERSION 3.0)

set(ME_CMAKE_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_cmake)
    set(
        X_OPTIONS
        FORCE
        NO_PC
        NO_CC
        NO_CXX
        NO_AR
        NO_NM
        NO_RANLIB
        NO_OBJCOPY
        NO_STRIP
        NO_INSTALL_NAME_TOOL
        NO_CROSS
        NO_CFLAGS
        NO_CXXFLAGS
        NO_SYS
        NO_RPATH
        NO_PREFIX
        NO_SYSROOT
        NO_GENERATOR
    )
    set(X_SINGLES SOURCE_DIR BUILD_DIR)
    set(X_MULTIS ENV FLAGS DEPENDS CCFLAGS CFLAGS CXXFLAGS)
    cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

    if(X_FORCE)
        list(APPEND X_DEPENDS ALWAYS)
    endif()

    if(NOT X_SOURCE_DIR)
        set(X_SOURCE_DIR ${ME_SOURCE_DIR})
    endif()

    if(NOT X_BUILD_DIR)
        set(X_BUILD_DIR ${ME_BUILD_DIR})
    endif()

    if(NOT X_NO_PC)
        list(APPEND X_ENV "PKG_CONFIG=${ME_PKG_CONFIG}")
    endif()
    if(NOT X_NO_PC AND ME_PKG_CONFIG_DIR)
        list(APPEND X_ENV "PKG_CONFIG_LIBDIR=${ME_PKG_CONFIG_DIR}")
    endif()
    if(NOT X_NO_CC)
        list(APPEND X_FLAGS "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
    endif()
    if(NOT X_NO_CXX)
        list(APPEND X_FLAGS "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
    endif()
    if(NOT X_NO_AR)
        list(APPEND X_FLAGS "-DCMAKE_AR=${CMAKE_AR}")
    endif()
    if(NOT X_NO_NM)
        list(APPEND X_FLAGS "-DCMAKE_NM=${CMAKE_NM}")
    endif()
    if(NOT X_NO_RANLIB)
        list(APPEND X_FLAGS "-DCMAKE_RANLIB=${CMAKE_RANLIB}")
    endif()
    if(NOT X_NO_OBJCOPY)
        list(APPEND X_FLAGS "-DCMAKE_OBJCOPY=${CMAKE_OBJCOPY}")
    endif()
    if(NOT X_NO_STRIP)
        list(APPEND X_FLAGS "-DCMAKE_STRIP=${CMAKE_STRIP}")
    endif()
    if(NOT X_NO_INSTALL_NAME_TOOL)
        list(APPEND X_FLAGS "-DCMAKE_INSTALL_NAME_TOOL=${CMAKE_INSTALL_NAME_TOOL}")
    endif()
    if(NOT X_NO_CROSS)
        list(APPEND X_FLAGS "-DCMAKE_CROSSCOMPILING=ON")
    endif()
    if(NOT X_NO_RPATH)
        list(APPEND X_FLAGS "-DCMAKE_SKIP_BUILD_RPATH=ON")
    endif()

    # Detect build type.
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Debug")
    endif()
    string(TOUPPER ${CMAKE_BUILD_TYPE} X_BUILD_TYPE)

    # Set CFLAGS environment.
    unset(CFLAGS)
    foreach(FLAGS ${X_CCFLAGS} ${X_CFLAGS})
        string(CONCAT CFLAGS ${CFLAGS} " " ${FLAGS})
    endforeach()
    if(NOT X_NO_CFLAGS)
        foreach(FLAGS ${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${X_BUILD_TYPE}})
            string(CONCAT CFLAGS ${CFLAGS} " " ${FLAGS})
        endforeach()
    endif()
    list(APPEND X_ENV "CFLAGS=${CFLAGS}")

    # Set CXXFLAGS environment.
    unset(CXXFLAGS)
    foreach(FLAGS ${X_CCFLAGS} ${X_CXXFLAGS})
        string(CONCAT CXXFLAGS ${CXXFLAGS} " " ${FLAGS})
    endforeach()
    if(NOT X_NO_CXXFLAGS)
        foreach(FLAGS ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${X_BUILD_TYPE}})
            string(CONCAT CXXFLAGS ${CXXFLAGS} " " ${FLAGS})
        endforeach()
    endif()
    list(APPEND X_ENV "CXXFLAGS=${CXXFLAGS}")

    if(NOT X_NO_SYS)
        list(APPEND X_FLAGS "-DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}")
    endif()
    if(NOT X_NO_PREFIX)
        list(APPEND X_FLAGS "-DCMAKE_INSTALL_PREFIX=${ME_INSTALL_PREFIX}")
    endif()
    if(NOT X_NO_SYSROOT AND ME_SYSROOT)
        list(APPEND X_FLAGS "-DCMAKE_OSX_SYSROOT=${ME_SYSROOT}")
        list(APPEND X_FLAGS "-DCMAKE_FIND_ROOT_PATH=${ME_SYSROOT}")
    endif()
    if(NOT X_NO_GENERATOR)
        list(APPEND X_FLAGS "-G${CMAKE_GENERATOR}")
    else()
        set(CMAKE_MAKE_PROGRAM make PARENT_SCOPE)
    endif()

    list(APPEND X_FLAGS "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")

    add_custom_command(
        OUTPUT ${X_BUILD_DIR}/Makefile
        COMMENT "[${ME_PROJECT}] configure"
        COMMAND ${CMAKE_COMMAND}
        -D "PROJECT=${ME_PROJECT}"
        -D "ENVIRONMENTS=${X_ENV}"
        -D "FLAGS=${X_FLAGS}"
        -D "SOURCE_DIR=${X_SOURCE_DIR}"
        -D "BUILD_DIR=${X_BUILD_DIR}"
        -P "${ME_CMAKE_SCRIPT}"
        DEPENDS ${X_DEPENDS} ${X_FILE}
        VERBATIM
    )
endfunction(me_cmake)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE OR x$ENV{ALL} STREQUAL x)
    return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/MeExports.cmake)
me_exports(${PROJECT} ${ENVIRONMENTS})

if(NOT x$ENV{DEBUG}$ENV{VERBOSE} STREQUAL x)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E echo
        [${PROJECT}] ${CMAKE_COMMAND} ${FLAGS} ${SOURCE_DIR}
    )
endif()

file(MAKE_DIRECTORY ${BUILD_DIR})

set(ERROR_MESSAGE "Configure failed:")
if(x$ENV{VERBOSE} STREQUAL x)
    list(APPEND OUTPUT_REDIRECT OUTPUT_FILE cmake-output.txt)
    string(
        CONCAT ERROR_MESSAGE
        "${ERROR_MESSAGE}" "\n"
        "STDOUT: ${BUILD_DIR}/cmake-output.txt"
    )
endif()
if(x$ENV{DEBUG}$ENV{VERBOSE} STREQUAL x)
    list(APPEND OUTPUT_REDIRECT ERROR_FILE cmake-error.txt)
    string(
        CONCAT ERROR_MESSAGE
        "${ERROR_MESSAGE}" "\n"
        "STDERR: ${BUILD_DIR}/cmake-error.txt"
    )
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} ${FLAGS} ${SOURCE_DIR}
    ${OUTPUT_REDIRECT}
    RESULT_VARIABLE error
    WORKING_DIRECTORY ${BUILD_DIR}
)
if(error)
    message(FATAL_ERROR "${ERROR_MESSAGE}")
endif()
