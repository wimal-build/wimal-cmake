set(ME_PACKAGE_CONFIG_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_package_config)
    if(CMAKE_SCRIPT_MODE_FILE)
        return()
    endif()
    file(REMOVE "${CMAKE_BINARY_DIR}/pc/pkg-config")
    file(REMOVE "${CMAKE_BINARY_DIR}/pkg-config")
    find_package(PkgConfig)
    if(NOT PKG_CONFIG_FOUND)
        message(FATAL_ERROR "No pkg-config found")
    endif()
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/pc")
    file(
        WRITE "${CMAKE_BINARY_DIR}/pc/pkg-config"
        "[ \"\$PACKAGE_CONFIG_SHARED\" = \"\" ] && ARGS=--static\n"
        "${PKG_CONFIG_EXECUTABLE} \$ARGS \$@"

    )
    file(
        COPY "${CMAKE_BINARY_DIR}/pc/pkg-config"
        DESTINATION "${CMAKE_BINARY_DIR}"
        FILE_PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE
    )
    set(ME_PKG_CONFIG "${CMAKE_BINARY_DIR}/pkg-config" CACHE PATH ME_PKG_CONFIG)
endfunction(me_package_config)
