find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Quick Concurrent Sql Network DBus)
find_package(PkgConfig REQUIRED)
pkg_check_modules(Qalculate IMPORTED_TARGET libqalculate REQUIRED)
pkg_check_modules(Pipewire IMPORTED_TARGET libpipewire-0.3 REQUIRED)
pkg_check_modules(Aubio IMPORTED_TARGET aubio REQUIRED)
pkg_check_modules(Cava IMPORTED_TARGET libcava QUIET)
if(NOT Cava_FOUND)
    pkg_check_modules(Cava IMPORTED_TARGET cava REQUIRED)
endif()

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
qt_standard_project_setup(REQUIRES 6.9)

function(qml_module arg_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI" "SOURCES;LIBRARIES")
    qt_add_qml_module(${arg_TARGET}
        URI ${arg_URI}
        VERSION 1.0
        SOURCES ${arg_SOURCES}
    )

    qt_query_qml_module(${arg_TARGET}
        URI module_uri
        VERSION module_version
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
    )
	set(module_dir "${INSTALL_QMLDIR}/${module_target_path}")
    install(TARGETS ${arg_TARGET} LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(TARGETS "${module_plugin_target}" LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")
    target_link_libraries(${arg_TARGET} PRIVATE Qt::Core Qt::Qml ${arg_LIBRARIES})
endfunction()

qml_module(ZShell
    URI ZShell
    SOURCES
        writefile.hpp writefile.cpp
        appdb.hpp appdb.cpp
        imageanalyser.hpp imageanalyser.cpp
		requests.hpp requests.cpp
		toaster.hpp toaster.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
        Qt::Sql
)

add_subdirectory(Models)
add_subdirectory(Internal)
add_subdirectory(Services)
