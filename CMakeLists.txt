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

add_library(Scorch::Protocol ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
	PUBLIC
		CapnProto::capnp
)

target_include_directories(${PROJECT_NAME}
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/schema>
		$<INSTALL_INTERFACE:include>
)

target_compile_features(${PROJECT_NAME}
	PUBLIC
		cxx_std_20
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(
	TARGETS ${PROJECT_NAME}
	EXPORT ScorchProtocolTargets
	ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(
	FILES
		${CAPNP_HDRS}
	DESTINATION
		${CMAKE_INSTALL_INCLUDEDIR}/scorch/protocol
)

install(
	EXPORT ScorchProtocolTargets
	FILE ScorchProtocolTargets.cmake
	NAMESPACE Scorch::
	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ScorchProtocol
)

configure_package_config_file(
	cmake/ScorchProtocolConfig.cmake.in
	${CMAKE_CURRENT_BINARY_DIR}/ScorchProtocolConfig.cmake
	INSTALL_DESTINATION
		${CMAKE_INSTALL_LIBDIR}/cmake/ScorchProtocol
)

write_basic_package_version_file(
	${CMAKE_CURRENT_BINARY_DIR}/ScorchProtocolConfigVersion.cmake
	VERSION ${PROJECT_VERSION}
	COMPATIBILITY SameMajorVersion
)

install(
	FILES
		${CMAKE_CURRENT_BINARY_DIR}/ScorchProtocolConfig.cmake
		${CMAKE_CURRENT_BINARY_DIR}/ScorchProtocolConfigVersion.cmake
	DESTINATION
		${CMAKE_INSTALL_LIBDIR}/cmake/ScorchProtocol
)
