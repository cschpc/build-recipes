cmake_minimum_required(VERSION 3.28)

set(objs objs)
set(static_library ${PROJECT_NAME})
set(binary ${PROJECT_NAME}-cli)

add_library(${static_library} STATIC)
add_library(${objs} OBJECT "")
add_executable(${binary})

target_sources(
    ${objs}
    PRIVATE
    kernels.cpp
    )

target_sources(
    ${binary}
    PRIVATE
    main.cpp
    )

target_include_directories(${objs} PRIVATE
    "${PROJECT_BINARY_DIR}/src"
    "${CMAKE_CURRENT_LIST_DIR}"
)

target_link_libraries(${objs} PUBLIC
    Kokkos::kokkos
)
target_link_libraries(${static_library} PUBLIC
    ${objs}
)
target_link_libraries(${binary} PRIVATE
    ${static_library}
)

install(
    TARGETS ${static_library} ${binary}
    CONFIGURATIONS Release RelWithDebInfo Debug
    ARCHIVE DESTINATION ${project_install_dir}/lib
    LIBRARY DESTINATION ${project_install_dir}/lib
    RUNTIME DESTINATION ${project_install_dir}/bin
    PUBLIC_HEADER DESTINATION ${project_install_dir}/include
    )
