pragma Singleton

import Quickshell
import Quickshell.Io
import qs.Config
import qs.Modules
import ZShell.Models

Searcher {
    id: root

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: true
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    // FileView {
    //     path: root.currentNamePath
    //     watchChanges: true
    //     onFileChanged: reload()
    //     onLoaded: {
    //         root.actualCurrent = text().trim();
    //     }
    // }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Config.wallpaperPath
        filter: FileSystemModel.Images
    }
}
