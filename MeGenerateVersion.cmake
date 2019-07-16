cmake_minimum_required(VERSION 3.0)

set(ME_GENERATE_VERSION_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_generate_version output name major minor build)
    add_custom_command(
        OUTPUT ${output}
        COMMENT "[${ME_PROJECT}] version"
        COMMAND ${CMAKE_COMMAND}
        -DME_NAME=${name}
        -DME_MAJOR=${major}
        -DME_MINOR=${minor}
        -DME_BUILD=${build}
        -DME_FULL=${major}.${minor}.${build}
        -DME_OUTPUT=${output}
        -P ${ME_GENERATE_VERSION_SCRIPT}
        DEPENDS ALWAYS
    )
endfunction(me_generate_version)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
    return()
endif()

file(
    WRITE version.cpp.in
    "
        namespace \@ME_NAME\@ {
            const char *MAJOR_VERSION = \"\@ME_MAJOR\@\";
            const char *MINOR_VERSION = \"\@ME_MINOR\@\";
            const char *BUILD_VERSION = \"\@ME_BUILD\@\";
            const char *VERSION = \"\@ME_FULL\@\";
        }
    "
)
configure_file(version.cpp.in ${ME_OUTPUT} @ONLY)
