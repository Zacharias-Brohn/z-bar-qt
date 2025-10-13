pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root
    property string activeWindow: Hyprland.activeToplevel?.title || ""
}
