<div align="center">
    <img src="/images/shell.png">
</div>
# ZShell

A feature-rich desktop shell for Hyprland built with [Quickshell](https://quickshell.outfoxxed.me/) and Qt6/QML. Provides a modern, Material Design 3 inspired status bar, application launcher, notification center, wallpaper manager with dynamic color theming, and lock screen.

## Features

- **Status Bar** - Configurable top panel with workspace indicators, audio controls, system resource monitors (CPU/RAM/GPU), system tray, clock with calendar, and notification bell
- **Application Launcher** - Fuzzy search with app frequency tracking, special search prefixes for filtering by category, description, keywords, etc.
- **Notification Center** - Full notification daemon with grouped notifications, popups, persistent storage, and Do Not Disturb mode
- **Wallpaper Manager** - Browse and select wallpapers with live preview carousel
- **Dynamic Color Theming** - Automatic Material Design 3 color palette generation from wallpapers
- **Lock Screen** - Secure session lock with PAM authentication
- **Hyprland Integration** - Deep integration with Hyprland for workspaces, window focus, keyboard state, and more

## Dependencies

- Qt 6.9+
- [Quickshell](https://quickshell.outfoxxed.me/)
- [Hyprland](https://hyprland.org/)
- Python 3 with `materialyoucolor` and `Pillow` (for dynamic color generation)
- PipeWire (for audio)

## Installation

```bash
cmake -B build -G Ninja
ninja -C build
sudo ninja -C build install
```

This installs the QML plugin to `/usr/lib/qt6/qml`.

## Configuration

Configuration is stored in `~/.config/z-bar/config.json`. Options include:

| Option                            | Description                                                 |
| --------------------------------- | ----------------------------------------------------------- |
| `appCount`                        | Max apps shown in launcher                                  |
| `wallpaperPath`                   | Directory containing wallpapers                             |
| `baseBgColor` / `baseBorderColor` | Fallback colors when dynamic colors disabled                |
| `accentColor`                     | Custom accent color override                                |
| `useDynamicColors`                | Enable Material Design 3 theming from wallpaper             |
| `barConfig`                       | Enable/disable widgets and configure popouts                |
| `transparency`                    | UI transparency levels                                      |
| `baseFont`                        | System font                                                 |
| `animScale`                       | Animation speed multiplier                                  |
| `gpuType`                         | GPU type for resource monitoring (`amd`, `nvidia`, `intel`) |

## Launcher Search Prefixes

| Prefix | Filter              |
| ------ | ------------------- |
| `>i`   | App ID              |
| `>c`   | Categories          |
| `>d`   | Description/comment |
| `>e`   | Exec command        |
| `>w`   | WM class            |
| `>g`   | Generic name        |
| `>k`   | Keywords            |
| `>t`   | Terminal apps only  |
| `> `   | Wallpaper picker    |

## Project Structure

```
├── shell.qml          # Main entry point
├── Bar.qml            # Status bar
├── Wallpaper.qml      # Wallpaper display layer
├── Components/        # Reusable UI components
├── Config/            # Configuration singletons
├── Modules/           # Main functional modules (Launcher, NotificationCenter, etc.)
├── Daemons/           # Background services (notifications, audio)
├── Helpers/           # Utility singletons
├── Plugins/ZShell/    # Native C++ plugins
└── scripts/           # Helper scripts (color generation, fuzzy search)
```

## License

See repository for license information.
