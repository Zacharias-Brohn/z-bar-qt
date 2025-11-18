pragma Singleton

import ZShell
import Quickshell
import Quickshell.Io

Searcher {
    id: root

    readonly property string home: Quickshell.env("HOME")

    function launch(entry: DesktopEntry): void {
        appDb.incrementFrequency(entry.id);

        console.log( "Search command:", entry.command );

        Quickshell.execDetached({
            command: ["app2unit", "--", ...entry.command],
            workingDirectory: entry.workingDirectory
        });
    }

    function search(search: string): list<var> {
        const prefix = ">";
        if (search.startsWith(`${prefix}i `)) {
            keys = ["id", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}c `)) {
            keys = ["categories", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}d `)) {
            keys = ["comment", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}e `)) {
            keys = ["execString", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}w `)) {
            keys = ["startupClass", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}g `)) {
            keys = ["genericName", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}k `)) {
            keys = ["keywords", "name"];
            weights = [0.9, 0.1];
        } else {
            keys = ["name"];
            weights = [1];

            if (!search.startsWith(`${prefix}t `))
                return query(search).map(e => e.entry);
        }

        const results = query(search.slice(prefix.length + 2)).map(e => e.entry);
        if (search.startsWith(`${prefix}t `))
            return results.filter(a => a.runInTerminal);
        return results;
    }

    function selector(item: var): string {
        return keys.map(k => item[k]).join(" ");
    }

    list: appDb.apps
    useFuzzy: true

    AppDb {
        id: appDb

        path: `${root.home}/.local/share/z-cast-qt/apps.sqlite`
        entries: DesktopEntries.applications.values
    }
}
