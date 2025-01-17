MAKEFLAGS += --silent
.SHELLFLAGS = -ec

this_file := $(lastword $(MAKEFILE_LIST))

project_name:=kokkos-example
root_dir:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
source_dir:=$(root_dir)
build_dir_prefix:=$(root_dir)/build

build_type=Release
build_dir=$(build_dir_prefix)/$(build_type)
common_args=-B $(build_dir) \
	    -S $(source_dir) \
	    -DCMAKE_BUILD_TYPE:STRING=$(build_type) \
	    -Dproject_name=$(project_name) \
	    -DCMAKE_INSTALL_PREFIX=$(root_dir) \
	    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

.PHONY: cuda hip openmp clean build

.ONESHELL:
cuda:
	cmake \
		$(common_args) \
		-DKokkos_ENABLE_CUDA=ON \
		-DKokkos_ARCH_AMPERE80=ON \
		-DKokkos_ENABLE_OPENMP=ON

	$(MAKE) -f $(this_file) build

.ONESHELL:
hip:
	cmake \
		$(common_args) \
		-DCMAKE_CXX_COMPILER=hipcc \
		-DKokkos_ENABLE_HIP=ON \
		-DKokkos_ARCH_AMD_GFX90A=ON \
		-DKokkos_ENABLE_OPENMP=ON

	$(MAKE) -f $(this_file) build

.ONESHELL:
openmp:
	cmake \
		$(common_args) \
		-DCMAKE_CXX_COMPILER=g++ \
		-DKokkos_ENABLE_OPENMP=ON

	$(MAKE) -f $(this_file) build

clean:
	rm -rf $(build_dir_prefix) $(project_name)

.ONESHELL:
build:
	cmake \
		--build $(build_dir) \
		--target install \
		-j8

	ln -s $(build_dir)/compile_commands.json compile_commands.json
