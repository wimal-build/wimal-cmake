# Include this cmake file to get the root of the project.
cmake_minimum_required(VERSION 3.0)

if(ME_ROOT_DIR)
    return()
endif()

get_filename_component(ME_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)

set(
    ME_ROOT_DIR ${ME_ROOT_DIR}
    CACHE INTERNAL
    "The root directory of the entire project"
)
set(
    ME_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR}
    CACHE INTERNAL
    "Directory containing cmake modules"
)

message(STATUS "Root: ${ME_ROOT_DIR}")
