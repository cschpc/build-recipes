#include <Kokkos_Core.hpp>
#include <cstdio>

int run(int argc, char **argv) {
    Kokkos::ScopeGuard kokkos(argc, argv);

    printf("Hello Kokkos!\n");
    return 0;
}
