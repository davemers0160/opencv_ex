# ----------------------------------------------------------------------------
#  Root CMake file for teh project
# ----------------------------------------------------------------------------
#
# To perform an out of source build do the following on the command line:
# 1. navigate to the root project directory (in this case DfD2)
# 2. mkdir build
# 3. cd build
# 4. depending on your system (windows/linux) type the following
# Example CMake build line for windows & VS2015
# windows: cmake -G "Visual Studio 14 2015 Win64" -DUSE_AVX_INSTRUCTIONS=ON ..
# linux: cmake -DUSE_AVX_INSTRUCTIONS=ON ..
#
# 5. To compile:
# windows: cmake --build . --config Release
# linux: cmake --build . --config Release -- -j4
#


cmake_minimum_required(VERSION 3.6)

#set(CMAKE_CXX_STANDARD 11)
#set(CMAKE_CXX_STANDARD_REQUIRED ON)

PROJECT(web_cam_stream_ex)
set(exe_name "cam")

set (CMAKE_CXX_STANDARD 17)

# This looks for an environment variable called PLATFORM.  This can be used to point
# cmake to various locations based on the individual machines that the code is complied on
set(PLATFORM "$ENV{PLATFORM}" CACHE INTERNAL "Copied from environment variable")
if("${PLATFORM}" STREQUAL "")
    set(PLATFORM "NOT_SET")
    message("The PLATFORM Environment variable is not set on this system.  Setting it to:")
endif()
message("Platform: " ${PLATFORM})

# find the root of the main project
string(FIND ${PROJECT_SOURCE_DIR} "/" INDEX REVERSE)
string(SUBSTRING ${PROJECT_SOURCE_DIR} 0 ${INDEX} PR_ROOT)

if(WIN32)
    if(${PLATFORM} STREQUAL "Laptop")
        set(COMMON_ROOT "D:/Common")
    elseif(${PLATFORM} STREQUAL "LaptopN")
        set(COMMON_ROOT "C:/Projects/Common")
    else()
        set(COMMON_ROOT "C:/Projects/Common")
    endif()
        
    
else()
    if(${PLATFORM} STREQUAL "MainGear")
        set(_ECLIPSE_VERSION "3.8")
        set(COMMON_ROOT "~/Common")
    elseif(${PLATFORM} STREQUAL "HPC")
        set(COMMON_ROOT "$HOME/Common")
    else()
        set(COMMON_ROOT "~/Projects/Common")
    endif()
    
    set(CMAKE_CXX_FLAGS "-O3")
    	
endif()

# look for any *.c and *.cpp files
file(GLOB SOURCES "src/*.c*"
    )

set(project_includes "include" 
    "${PR_ROOT}/common/include"
    "${COMMON_ROOT}/include" 
    )


# look for opencv
message(STATUS "--------------------------------------------------------------------------------")
message(STATUS "Looking for OpenCV installation...")
find_package(OpenCV REQUIRED)
if (OpenCV_FOUND)
	set(project_includes ${project_includes} ${OpenCV_INCLUDE_DIRS})
	set(project_libs ${project_libs} ${OpenCV_LIBS})
	message(STATUS "Found OpenCV: " ${OpenCV_DIR})
else()
	message("OpenCV not found...")
endif()
message(STATUS "--------------------------------------------------------------------------------")


message(" ")
message(STATUS "--------------------------------------------------------------------------------")
message("Source Files: ")
foreach(S ${SOURCES})
    message("  " ${S})
endforeach()
message(STATUS "--------------------------------------------------------------------------------")

message(" ")

message(STATUS "--------------------------------------------------------------------------------")
message("Project Includes: ")
foreach(S ${project_includes})
    message("  " ${S})
endforeach()
message(STATUS "--------------------------------------------------------------------------------")

message(" ")

message(STATUS "--------------------------------------------------------------------------------")
message("Project Libraries: ")
foreach(S ${project_libs})
    message("  " ${S})
endforeach()
message(STATUS "--------------------------------------------------------------------------------")

message(" ")

include_directories(${project_includes})
add_executable(${exe_name} ${SOURCES})
target_link_libraries(${exe_name} ${project_libs})

if(WIN32)
    message("MSVC Version: " ${MSVC_VERSION})
    # uncomment for MSVC and cmake greater than 3.6.0
    set(default_build_type "Release")
    if(MSVC AND (${CMAKE_VERSION} VERSION_GREATER "3.6.0"))
        target_compile_options(${exe_name} PRIVATE "/MP")
        set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${exe_name})
    endif()

endif()

message(" ")
message(STATUS "Build Complete!")
message(" ")

