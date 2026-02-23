pragma Singleton

import Quickshell

Singleton {
    id: root

    function getTrayIcon(id: string, icon: string): string {
        if (icon.includes("?path=")) {
            const [name, path] = icon.split("?path=");
            icon = Qt.resolvedUrl(`${path}/${name.slice(name.lastIndexOf("/") + 1)}`);
        } else if (icon.includes("qspixmap") && id === "chrome_status_icon_1") {
            icon = icon.replace("qspixmap", "icon/discord-tray");
        }
        return icon;
    }
}
