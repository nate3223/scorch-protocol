cmake_minimum_required(VERSION 3.25)

if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
	set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")
endif()

project(
	ScorchProtocol
	VERSION 0.1.1
	LANGUAGES CXX
)

find_package(CapnProto CONFIG REQUIRED)

capnp_generate_cpp(
	CAPNP_SRCS
	CAPNP_HDRS
	${CMAKE_CURRENT_SOURCE_DIR}/schema/ScorchProtocol.capnp
)

add_library(${PROJECT_NAME} STATIC
	${CAPNP_SRCS}
	${CAPNP_HDRS}
)

target_link_libraries(${PROJECT_NAME} PUBLIC
	CapnProto::capnp
)

target_include_directories(${PROJECT_NAME} PUBLIC
	${CMAKE_CURRENT_BINARY_DIR}/schema
)

target_compile_features(${PROJECT_NAME} PUBLIC
	cxx_std_20
)

add_library(Scorch::Protocol ALIAS ScorchProtocol)
