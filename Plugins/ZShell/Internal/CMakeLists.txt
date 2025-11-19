qml_module(ZShell-internal
    URI ZShell.Internal
    SOURCES
        hyprextras.hpp hyprextras.cpp
        hyprdevices.hpp hyprdevices.cpp
        cachingimagemanager.hpp cachingimagemanager.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
        Qt::Core
)
