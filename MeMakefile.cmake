cmake_minimum_required(VERSION 3.0)

macro(add_compile_options)
endmacro(add_compile_options)

macro(add_custom_command)
endmacro(add_custom_command)

macro(add_custom_target)
endmacro(add_custom_target)

macro(add_dependencies)
endmacro(add_dependencies)

macro(add_executable)
endmacro(add_executable)

macro(add_library)
endmacro(add_library)

macro(add_subdirectory)
endmacro(add_subdirectory)

macro(configure_file)
endmacro(configure_file)

macro(include_directories)
endmacro(include_directories)

macro(install)
endmacro(install)

macro(project)
endmacro(project)

macro(set_property)
endmacro(set_property)

macro(set_target_properties)
endmacro(set_target_properties)

macro(target_include_directories)
endmacro(target_include_directories)

macro(target_link_libraries)
endmacro(target_link_libraries)

macro(try_compile)
endmacro(try_compile)

function(me_makefile_make target)
    if(NOT TARGET)
        set(TARGET x64-linux)
    endif()

    if(NOT BUILD_TYPE)
        set(BUILD_TYPE Debug)
    endif()

    string(TOLOWER ${BUILD_TYPE} BUILD_TYPE_NAME)
    set(TARGET_DIR "${ME_ROOT_DIR}/target/${TARGET}-${BUILD_TYPE_NAME}")
    set(BUILD_DIR "${ME_ROOT_DIR}/build/${TARGET}-${BUILD_TYPE_NAME}")

    if(CLEAN)
        if (NOT x$ENV{DIST} STREQUAL x)
            set(DISTCLEAN ON)
        else()
            message(STATUS "Clear directory ${BUILD_DIR}/${target}")
            file(REMOVE_RECURSE "${BUILD_DIR}/${target}")
            return()
        endif()
    endif()

    if(DISTCLEAN)
        message(STATUS "Clear directory ${BUILD_DIR}")
        file(REMOVE_RECURSE "${BUILD_DIR}")
        return()
    endif()

    file(MAKE_DIRECTORY "${BUILD_DIR}")

    if (NOT x$ENV{DIST} STREQUAL x)
        set(ENV{ALL} 1)
    endif()

    find_program(Ninja NAMES ninja ninja-build)

    if(Ninja STREQUAL Ninja-NOTFOUND)
        message(STATUS "Ninja not found, use make instead.")
    else()
        message(STATUS "Found Ninja: ${Ninja}")
        set(ME_GENERATOR "-GNinja")
    endif()

    get_filename_component(STDOUT /proc/self/fd/1 REALPATH)
    if(EXISTS ${STDOUT})
        set(OUTPUT_FILE OUTPUT_FILE ${STDOUT})
    endif()

    execute_process(
        COMMAND ${CMAKE_COMMAND} ${ME_GENERATOR}
        "-DCMAKE_TOOLCHAIN_FILE=${ME_CMAKE_DIR}/MeToolchain.cmake"
        "-DWIMAL_TARGET=${TARGET}"
        "-DCMAKE_BUILD_TYPE=${BUILD_TYPE}"
        "-DCMAKE_INSTALL_PREFIX=${TARGET_DIR}"
        "-DME_EXTRA_PROJECTS=${target}"
        "${ME_ROOT_DIR}"
        ${OUTPUT_FILE}
        WORKING_DIRECTORY "${BUILD_DIR}"
        RESULT_VARIABLE SUCCESS
    )
    if(NOT SUCCESS EQUAL 0)
        return()
    endif()

    if (x$ENV{DIST} STREQUAL x)
        if(ME_INSTALL)
            set(target install-${target})
        else()
            set(target ${target}-)
        endif()
    endif()

    execute_process(
        COMMAND ${CMAKE_COMMAND} --build . --target ${target}
        ${OUTPUT_FILE}
        WORKING_DIRECTORY "${BUILD_DIR}"
    )
endfunction(me_makefile_make)
