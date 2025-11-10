pragma Singleton

import Caelestia
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
        keys = ["name"];
        weights = [1];

        const results = query(search).map(e => e.entry);
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
