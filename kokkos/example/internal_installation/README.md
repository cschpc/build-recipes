## On LUMI
Modules to load:

```bash
# Needed for CMake >3.28
ml LUMI/24.03
ml partition/G
ml buildtools/24.03

# Needed for hipcc compilation
ml PrgEnv-amd
ml rocm

export HIPCC_COMPILE_FLAGS_APPEND="--offload-arch=gfx90a $(CC --cray-print-opts=cflags)"
export HIPCC_LINK_FLAGS_APPEND=$(CC --cray-print-opts=libs)
```

Then do `make hip` to build the code and `sbatch sbatch/lumi_gpu.sh` to run it.

## On Mahti
Modules to load:

```bash
ml gcc/10.4.0
ml cuda/12.6.1
```

Then do `make cuda` to build the code and `sbatch sbatch/mahti_gpu.sh` to run it.

## Locally
`make openmp` and `kokkos-example/v0.1.0.0/Release/bin/kokkos-example-cli` to run it.
