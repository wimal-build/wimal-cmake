# This cmake file is included in each subproject. It provides some functions for creating
# subprojects.
#
# - Use me_project() to create a project.
# - Use me_autoconf() / me_configure() / me_make() to build a GNU autotools project.
# - Use me_cmake() / me_make() to build a external cmake project.
cmake_minimum_required(VERSION 3.0)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

if(CMAKE_SCRIPT_MODE_FILE)
    include(MeMakefile)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/MeDetectRoot.cmake)
me_detect_root(${CMAKE_CURRENT_SOURCE_DIR}/..)

include(MeAutoconf)
include(MeBuild)
include(MeCMake)
include(MeConfigure)
include(MeDetectTarget)
include(MeDetectVersion)
include(MeGenerateHeader)
include(MeGenerateVersion)
include(MeImport)
include(MeMake)
include(MePkgConfig)
include(MeProject)

me_package_config()
me_detect_version()
me_detect_target(ME)

set(ME_BUILD_ROOT ${CMAKE_BINARY_DIR} CACHE INTERNAL ME_BUILD_ROOT)
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE BOOL CMAKE_BUILD_WITH_INSTALL_RPATH)
