MAKEFLAGS += --silent

project_name:=kokkos-example
root_dir:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
source_dir:=$(root_dir)
build_dir_prefix:=$(root_dir)/build

.PHONY: hip openmp

.ONESHELL:
hip:
	build_type=Release
	build_dir=$(build_dir_prefix)/$${build_type}
	cmake \
		-B $${build_dir} \
		-S $(source_dir) \
		-DCMAKE_BUILD_TYPE:STRING=$${build_type} \
		-Dproject_name=$(project_name) \
		-DCMAKE_CXX_COMPILER=hipcc \
		-DCMAKE_BUILD_TYPE=Release \
		-DKokkos_ENABLE_HIP=ON \
		-DKokkos_ARCH_AMD_GFX90A=ON \
		-DKokkos_ENABLE_OPENMP=ON \
		-DCMAKE_INSTALL_PREFIX=$(root_dir) \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake \
		--build $${build_dir} \
		--target install \
		-j8

.ONESHELL:
openmp:
	build_type=Release
	build_dir=$(build_dir_prefix)/$${build_type}
	cmake \
		-B $${build_dir} \
		-S $(source_dir) \
		-DCMAKE_BUILD_TYPE:STRING=$${build_type} \
		-Dproject_name=$(project_name) \
		-DCMAKE_CXX_COMPILER=g++ \
		-DCMAKE_BUILD_TYPE=Release \
		-DKokkos_ENABLE_OPENMP=ON \
		-DCMAKE_INSTALL_PREFIX=$(root_dir)
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake \
		--build $${build_dir} \
		--target install \
		-j8

clean:
	rm -rf $(build_dir_prefix) $(project_name)
