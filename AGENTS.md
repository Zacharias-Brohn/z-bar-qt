# Agent Guidelines for z-bar-qt

## Build & Test
- **Build**: `cmake -B build -G Ninja && ninja -C build` (uses CMake + Ninja)
- **Install**: `sudo ninja -C build install` (installs to /usr/lib/qt6/qml)
- **No test suite**: Project has no automated tests currently
- **Update script**: `scripts/update.sh` (runs `yay -Sy`)

## Code Style - C++
- **Standard**: C++20 with strict warnings enabled (see CMakeLists.txt line 14-20)
- **Headers**: `#pragma once` for header guards
- **Types**: Use [[nodiscard]] for getters, explicit constructors, const correctness
- **Qt Integration**: QML_ELEMENT/QML_UNCREATABLE macros, Q_PROPERTY for QML exposure
- **Naming**: camelCase for methods/variables, m_ prefix for member variables
- **Includes**: Qt headers with lowercase (qobject.h, qqmlintegration.h)
- **Namespaces**: Use `namespace ZShell` for plugin code

## Code Style - QML
- **Pragma**: Start with `pragma ComponentBehavior: Bound` for type safety
- **Imports**: Qt modules first, then Quickshell, then local (qs.Modules, qs.Config, qs.Helpers)
- **Aliases**: Use `qs` prefix for local module imports
- **Properties**: Use `required property` for mandatory bindings
- **Types**: Explicit type annotations in JavaScript (`: void`, `: string`)
- **Structure**: Components in Components/, Modules in Modules/, Config singletons in Config/
