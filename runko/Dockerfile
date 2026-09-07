# syntax=docker/dockerfile:1
#
# Build environment for Runko (HIP backend). Mount your source tree in and
# build inside the container. Does NOT build Runko itself.
#
# Requirements (https://runko.readthedocs.io/en/latest/installation.html):
#   Python >=3.11.7 (24.04 ships 3.12), CMake >=3.23, MPI,
#   HIP backend: LLVM 19-based compiler w/ HIP (ROCm's hipcc), tested with
#   GCC 14 libstdc++, ROCm 6.3.4.
#
# NOTE: stock OpenMPI here is not GPU-aware. Fine for compiling; a runnable
# HIP build would need a GPU-aware MPI.

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# Toolchain: GCC 14 (for the tested libstdc++), OpenMPI, Python, build tools.
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates gnupg wget git \
        build-essential \
        libopenmpi-dev openmpi-bin \
        python3 python3-dev python3-venv python3-pip \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y --no-install-recommends \
        gcc-14 g++-14 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 140 \
                           --slave   /usr/bin/g++ g++ /usr/bin/g++-14 \
    && rm -rf /var/lib/apt/lists/*

# ROCm 6.3.4 (hipcc + HIP dev stack) from AMD's apt repo. If apt can't find
# 'rocm-hip-sdk' or the 'noble' path, check AMD's ROCm 6.3.x install docs.
RUN mkdir -p /etc/apt/keyrings \
    && wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/rocm.gpg \
    && echo \
"deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.3.4 noble main" \
        > /etc/apt/sources.list.d/rocm.list \
    && printf 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600\n' \
        > /etc/apt/preferences.d/rocm-pin-600 \
    && apt-get update && apt-get install -y --no-install-recommends \
        rocm-hip-sdk \
    && rm -rf /var/lib/apt/lists/*

ENV ROCM_PATH="/opt/rocm"
ENV PATH="/opt/rocm/bin:${PATH}"
ENV CMAKE_PREFIX_PATH="/opt/rocm"

# Python venv (Runko requires installing into one). On PATH so no activation
# is needed. CMake >=3.23 via pip guarantees a new enough version.
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:${PATH}"
RUN pip install --no-cache-dir --upgrade \
        pip "cmake>=3.23" ninja scikit-build-core pybind11

# mpi4py built against this image's mpicc (a mismatched MPI causes problems).
RUN MPI4PY_BUILD_MPICC=mpicc \
    pip install --no-cache-dir --no-binary=mpi4py mpi4py

# Make the venv writable by any uid, so `pip install .` works when the
# container runs as your host user (--user). The image is disposable, so
# world-writable here is fine.
RUN chmod -R a+rwX /opt/venv

WORKDIR /src
CMD ["bash"]
