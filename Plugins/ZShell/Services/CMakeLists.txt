qml_module(ZShell-services
	URI ZShell.Services
    SOURCES
        service.hpp service.cpp
        serviceref.hpp serviceref.cpp
        beattracker.hpp beattracker.cpp
        audiocollector.hpp audiocollector.cpp
        audioprovider.hpp audioprovider.cpp
        cavaprovider.hpp cavaprovider.cpp
    LIBRARIES
        PkgConfig::Pipewire
        PkgConfig::Aubio
        PkgConfig::Cava
)
