cmake_minimum_required(VERSION 3.0)

set(ME_MAKE_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_make)
    set(X_OPTIONS)
    set(X_SINGLES BUILD_DIR)
    set(X_MULTIS TARGETS DEPENDS ENV OUTPUT)
    cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

    if(NOT X_BUILD_DIR)
        set(X_BUILD_DIR ${ME_BUILD_DIR})
    endif()

    if(NOT X_TARGETS)
        set(X_TARGETS install)
    endif()

    if(NOT X_OUTPUT)
        set(X_OUTPUT make)
    endif()

    add_custom_command(
        OUTPUT ${X_OUTPUT} ${${ME_PROJECT}-LIBS}
        COMMENT "[${ME_PROJECT}] make"
        COMMAND ${CMAKE_COMMAND}
        -D "PROJECT=${ME_PROJECT}"
        -D "ENVIRONMENTS=${X_ENV}"
        -D "CMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
        -D "TARGETS=${X_TARGETS}"
        -D "BUILD_DIR=${X_BUILD_DIR}"
        -P "${ME_MAKE_SCRIPT}"
        DEPENDS ${X_DEPENDS} "${X_BUILD_DIR}/Makefile"
        WORKING_DIRECTORY "${X_BUILD_DIR}"
        VERBATIM
    )
endfunction(me_make)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE OR x$ENV{ALL} STREQUAL x)
    return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/MeExports.cmake)
me_exports(${PROJECT} ${ENVIRONMENTS})

set(ERROR_MESSAGE "Make failed:")
if(x$ENV{VERBOSE} STREQUAL x)
    list(APPEND OUTPUT_REDIRECT OUTPUT_FILE make-output.txt)
    string(
        CONCAT ERROR_MESSAGE
        "${ERROR_MESSAGE}" "\n"
        "STDOUT: ${BUILD_DIR}/make-output.txt"
    )
endif()

execute_process(
    COMMAND ${CMAKE_MAKE_PROGRAM} ${TARGETS}
    ${OUTPUT_REDIRECT}
    RESULT_VARIABLE error
    WORKING_DIRECTORY ${BUILD_DIR}
)
if(error)
    message(FATAL_ERROR "${ERROR_MESSAGE}")
endif()
