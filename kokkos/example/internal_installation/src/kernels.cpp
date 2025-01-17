#include <Kokkos_Core.hpp>
#include <chrono>
#include <cstdio>

template <typename Lambda> double time_computation(Lambda lambda) {
    static constexpr size_t NUM_RUNS = 1000;

    // Warm up
    for (size_t i = 0; i < NUM_RUNS; i++) {
        lambda();
    }

    // Measure
    const auto begin = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < NUM_RUNS; i++) {
        lambda();
    }

    const auto end = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double, std::milli> milliseconds = end - begin;

    return milliseconds.count() / NUM_RUNS;
}

template <typename T>
void output(const char *str, double avg_runtime, const T &values) {
    static constexpr size_t NUM_TO_PRINT = 10;
    printf("%s[ms]: %f\n", str, avg_runtime);
    printf("First and last %lu values:\n", NUM_TO_PRINT);
    for (size_t i = 0; i < NUM_TO_PRINT - 1; i++) {
        printf("%f, ", values(i));
    }
    printf("%f, ..., ", values(NUM_TO_PRINT - 1));
    for (size_t i = 0; i < NUM_TO_PRINT - 1; i++) {
        printf("%f, ", values(values.size() - NUM_TO_PRINT + i));
    }
    printf("%f\n", values(values.size() - 1));
}

int run(int argc, char **argv) {
    static constexpr size_t NUM_VALUES = 10'000'000;
    Kokkos::ScopeGuard kokkos(argc, argv);

    Kokkos::View<float *, Kokkos::LayoutRight,
                 Kokkos::DefaultHostExecutionSpace,
                 Kokkos::MemoryTraits<Kokkos::Restrict>>
        host_a("host_a", NUM_VALUES);
    Kokkos::View<float *, Kokkos::LayoutRight,
                 Kokkos::DefaultHostExecutionSpace,
                 Kokkos::MemoryTraits<Kokkos::Restrict>>
        host_b("host_b", NUM_VALUES);
    Kokkos::View<float *, Kokkos::LayoutRight,
                 Kokkos::DefaultHostExecutionSpace,
                 Kokkos::MemoryTraits<Kokkos::Restrict>>
        host_c("host_c", NUM_VALUES);

    // Initialize the host values
    for (size_t i = 0; i < NUM_VALUES; i++) {
        host_a(i) = (float)(i);
        host_b(i) = (float)(i * 2);
        host_c(i) = 0.0f;
    }

    const auto dev_a = Kokkos::create_mirror_view_and_copy(
        Kokkos::DefaultExecutionSpace(), host_a);
    const auto dev_b = Kokkos::create_mirror_view_and_copy(
        Kokkos::DefaultExecutionSpace(), host_b);
    auto dev_c = Kokkos::create_mirror_view_and_copy(
        Kokkos::DefaultExecutionSpace(), host_c);

    const double cpu_avg_runtime = time_computation([&host_a, &host_b,
                                                     &host_c]() {
        Kokkos::parallel_for(
            "cpu_c=a+b",
            Kokkos::RangePolicy<Kokkos::DefaultHostExecutionSpace>(0,
                                                                   NUM_VALUES),
            KOKKOS_LAMBDA(const int i) { host_c(i) = host_a(i) + host_b(i); });
        Kokkos::fence();
    });

    const double gpu_avg_runtime = time_computation([&dev_a, &dev_b, &dev_c]() {
        Kokkos::parallel_for(
            "gpu_c=a+b",
            Kokkos::RangePolicy<Kokkos::DefaultExecutionSpace>(0, NUM_VALUES),
            KOKKOS_LAMBDA(const int i) { dev_c(i) = dev_a(i) + dev_b(i); });
        Kokkos::fence();
    });

    const auto host_view_of_dev_c = Kokkos::create_mirror_view(dev_c);

    output("CPU", cpu_avg_runtime, host_c);
    output("GPU", gpu_avg_runtime, host_view_of_dev_c);

    return 0;
}
