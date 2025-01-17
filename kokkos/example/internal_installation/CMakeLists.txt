cmake_minimum_required(VERSION 3.28)

project(${project_name} LANGUAGES CXX VERSION 0.1.0.0)
set(project_install_dir ${PROJECT_NAME}/v${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_TWEAK}/${CMAKE_BUILD_TYPE})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(FetchContent)
FetchContent_Declare(
    Kokkos
    GIT_REPOSITORY https://github.com/kokkos/kokkos.git
    GIT_TAG develop
    OVERRIDE_FIND_PACKAGE
    SYSTEM
    EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(Kokkos)

set(gcc "$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>")

set(debug_gcc "$<AND:$<CONFIG:Debug>,${gcc}>")

set(gcc_warn -Wall;-Werror;-Wextra;-Wconversion;-Wsign-conversion;)
set(gcc_warn ${gcc_warn};-pedantic-errors;-Wcast-qual;-Wwrite-strings;)
set(gcc_warn ${gcc_warn};-Wparentheses;)
set(gcc_warn ${gcc_warn};-Wlogical-not-parentheses;)
set(gcc_warn ${gcc_warn};-Wredundant-decls;-Wformat=2;)
set(gcc_warn ${gcc_warn};-Wformat-security;-Wformat-nonliteral;)
set(gcc_warn ${gcc_warn};-Wnull-dereference;-Winit-self;-Wuninitialized;)
set(gcc_warn ${gcc_warn};-Wpointer-arith;-Wundef;)

# These seem not to be recognized by hipcc
#set(gcc_warn ${gcc_warn};-Wlogical-op;-Wcast-align=strict;)
#set(gcc_warn ${gcc_warn};-Warith-conversion;-Wduplicated-branches;)
#set(gcc_warn ${gcc_warn};-Wduplicated-cond;-Wformat-signedness;)

set(gcc_deb_opt -Og;)
set(gcc_rel_opt -O3;)

add_compile_options(
    "$<${gcc}:${gcc_warn}>"
    "$<IF:${debug_gcc},${gcc_deb_opt},${gcc_rel_opt}>"
    )

add_subdirectory(src)
