# Recursively look for the parent directory to detect the project root directory.
#
# Variable ME_ROOT will be set to the project root directory on success.
#
# Will fail for standalone projects.
function(me_detect_root search)
    if(ME_ROOT_DIR)
        return()
    endif()

    if(NOT IS_ABSOLUTE ${search})
        get_filename_component(search ${search} ABSOLUTE)
    endif()

    if(NOT IS_DIRECTORY ${search})
        return()
    elseif(EXISTS "${search}/cmake/MeRoot.cmake")
        include(${search}/cmake/MeRoot.cmake)
    endif()

    if(NOT ME_ROOT_DIR)
        get_filename_component(next ${search}/.. ABSOLUTE)
        if(next STREQUAL search)
            set(ME_STANDALONE ON CACHE BOOL "The project is a standalone project." FORCE)
            include(MeRoot)
        else()
            me_detect_root(${next})
        endif()
    endif()
endfunction(me_detect_root)
