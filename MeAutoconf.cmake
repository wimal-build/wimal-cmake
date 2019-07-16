cmake_minimum_required(VERSION 3.0)

set(ME_AUTOCONF_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_autoconf)
    set(X_OPTIONS FORCE)
    set(X_SINGLES SOURCE_DIR)
    set(X_MULTIS ENV FLAGS DEPENDS)
    cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

    if(NOT X_SOURCE_DIR)
        set(X_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/sources)
    endif()

    if(NOT X_FLAGS)
        set(X_FLAGS -if --warnings=none)
    endif()

    if(X_FORCE)
        list(APPEND X_DEPENDS ALWAYS)
    endif()

    find_program(AUTORECONF autoreconf)
    if(AUTORECONF-NOTFOUND)
        message(FATAL_ERROR "autoreconf not found")
    endif()

    # Preferred to use glibtoolize on OSX
    find_program(LIBTOOLIZE NAMES glibtoolize libtoolize)
    if(LIBTOOLIZE-NOTFOUND)
        message(FATAL_ERROR "libtoolize not found")
    endif()
    list(APPEND X_ENV LIBTOOLIZE=${LIBTOOLIZE})

    add_custom_command(
        OUTPUT "${X_SOURCE_DIR}/configure"
        COMMENT "[${ME_PROJECT}] autoconf"
        COMMAND ${CMAKE_COMMAND}
        -D "PROJECT=${ME_PROJECT}"
        -D "ENVIRONMENTS=${X_ENV}"
        -D "PROGRAM=${AUTORECONF}"
        -D "FLAGS=${X_FLAGS}"
        -D "BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}"
        -P "${ME_AUTOCONF_SCRIPT}"
        WORKING_DIRECTORY "${X_SOURCE_DIR}"
        DEPENDS ${X_DEPENDS}
        VERBATIM
    )
endfunction()

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE OR x$ENV{ALL} STREQUAL x)
    return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/MeExports.cmake)
me_exports(${PROJECT} ${ENVIRONMENTS})

if(NOT x$ENV{DEBUG}$ENV{VERBOSE} STREQUAL x)
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo [${PROJECT}] ${PROGRAM} ${FLAGS})
endif()

set(ERROR_MESSAGE "Make failed:")
if(x$ENV{VERBOSE} STREQUAL x)
    list(APPEND OUTPUT_REDIRECT OUTPUT_FILE "${BUILD_DIR}/autoconf-output.txt")
    string(
        CONCAT ERROR_MESSAGE
        "${ERROR_MESSAGE}" "\n"
        "STDOUT: ${BUILD_DIR}/autoconf-output.txt"
    )
endif()
if(x$ENV{DEBUG}$ENV{VERBOSE} STREQUAL x)
    list(APPEND OUTPUT_REDIRECT ERROR_FILE "${BUILD_DIR}/autoconf-output.txt")
    string(
        CONCAT ERROR_MESSAGE
        "${ERROR_MESSAGE}" "\n"
        "STDERR: ${BUILD_DIR}/autoconf-error.txt"
    )
endif()

execute_process(COMMAND "${PROGRAM}" ${FLAGS} ${OUTPUT_REDIRECT} RESULT_VARIABLE error)
if(error)
    message(FATAL_ERROR "${ERROR_MESSAGE}")
endif()
