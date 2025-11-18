find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Quick Concurrent Sql)
find_package(PkgConfig REQUIRED)

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
    set(module_dir "/usr/lib/qt6/qml/${module_target_path}")
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
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
        Qt::Sql
)

add_subdirectory(Models)
add_subdirectory(Internal)
