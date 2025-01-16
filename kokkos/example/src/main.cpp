#include <Kokkos_Core.hpp>
#include <cstdio>

int foo(int a);

int main(int argc, char** argv) {
    Kokkos::initialize(argc, argv);
    printf("Hello world! Foo: %d\n", foo(1));
    Kokkos::finalize();
}
