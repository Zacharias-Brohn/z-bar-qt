cmake_minimum_required(VERSION 3.19)

project(ZShell)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(ENABLE_MODULES "plugin;shell" CACHE STRING "Modules to build/install")

set(INSTALL_LIBDIR "usr/lib/ZShell" CACHE STRING "Library install dir")
set(INSTALL_QMLDIR "usr/lib/qt6/qml" CACHE STRING "QML install dir")
set(INSTALL_QSCONFDIR "etc/xdg/quickshell/zshell" CACHE STRING "Quickshell config install dir")

add_compile_options(
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion
    -Wold-style-cast -Wnull-dereference -Wdouble-promotion
    -Wformat=2 -Wfloat-equal -Woverloaded-virtual
    -Wsign-conversion -Wredundant-decls -Wswitch
    -Wunreachable-code
)


if("plugin" IN_LIST ENABLE_MODULES)
	add_subdirectory(Plugins)
endif()

if("shell" IN_LIST ENABLE_MODULES)
	foreach(dir assets scripts Components Config Modules Daemons Drawers Effects Helpers Paths)
        install(DIRECTORY ${dir} DESTINATION "${INSTALL_QSCONFDIR}")
    endforeach()
	install(FILES shell.qml DESTINATION "${INSTALL_QSCONFDIR}")
endif()
