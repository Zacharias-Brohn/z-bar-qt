pragma Singleton

import Quickshell
import Quickshell.Io
import "../scripts/levendist.js" as Levendist
import "../scripts/fuzzysort.js" as Fuzzy
import qs.Config

Singleton {
	id: root

	readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values).filter((app, index, self) => index === self.findIndex(t => (t.id === app.id)))
	readonly property var preppedIcons: list.map(a => ({
				name: Fuzzy.prepare(`${a.icon} `),
				entry: a
			}))
	readonly property var preppedNames: list.map(a => ({
				name: Fuzzy.prepare(`${a.name} `),
				entry: a
			}))
	property var regexSubstitutions: [
		{
			"regex": /^steam_app_(\d+)$/,
			"replace": "steam_icon_$1"
		},
		{
			"regex": /Minecraft.*/,
			"replace": "minecraft"
		},
		{
			"regex": /.*polkit.*/,
			"replace": "system-lock-screen"
		},
		{
			"regex": /gcr.prompter/,
			"replace": "system-lock-screen"
		}
	]
	readonly property real scoreGapThreshold: 0.1
	readonly property real scoreThreshold: 0.6
	property var substitutions: ({
			"code-url-handler": "visual-studio-code",
			"Code": "visual-studio-code",
			"gnome-tweaks": "org.gnome.tweaks",
			"pavucontrol-qt": "pavucontrol",
			"wps": "wps-office2019-kprometheus",
			"wpsoffice": "wps-office2019-kprometheus",
			"footclient": "foot"
		})

	function bestFuzzyEntry(search: string, preppedList: list<var>, key: string): var {
		const results = Fuzzy.go(search, preppedList, {
			key: key,
			threshold: root.scoreThreshold,
			limit: 2
		});

		if (!results || results.length === 0)
			return null;

		const best = results[0];
		const second = results.length > 1 ? results[1] : null;

		if (second && (best.score - second.score) < root.scoreGapThreshold)
			return null;

		return best.obj.entry;
	}

	function fuzzyQuery(search: string, preppedList: list<var>): var {
		const entry = bestFuzzyEntry(search, preppedList, "name");
		return entry ? [entry] : [];
	}

	function getKebabNormalizedAppName(str: string): string {
		return str.toLowerCase().replace(/\s+/g, "-");
	}

	function getReverseDomainNameAppName(str: string): string {
		return str.split('.').slice(-1)[0];
	}

	function getUndescoreToKebabAppName(str: string): string {
		return str.toLowerCase().replace(/_/g, "-");
	}

	function guessIcon(str) {
		if (!str || str.length == 0)
			return "image-missing";

		if (iconExists(str))
			return str;

		const entry = DesktopEntries.byId(str);
		if (entry)
			return entry.icon;

		const heuristicEntry = DesktopEntries.heuristicLookup(str);
		if (heuristicEntry)
			return heuristicEntry.icon;

		if (substitutions[str])
			return substitutions[str];
		if (substitutions[str.toLowerCase()])
			return substitutions[str.toLowerCase()];

		for (let i = 0; i < regexSubstitutions.length; i++) {
			const substitution = regexSubstitutions[i];
			const replacedName = str.replace(substitution.regex, substitution.replace);
			if (replacedName != str)
				return replacedName;
		}

		const lowercased = str.toLowerCase();
		if (iconExists(lowercased))
			return lowercased;

		const reverseDomainNameAppName = getReverseDomainNameAppName(str);
		if (iconExists(reverseDomainNameAppName))
			return reverseDomainNameAppName;

		const lowercasedDomainNameAppName = reverseDomainNameAppName.toLowerCase();
		if (iconExists(lowercasedDomainNameAppName))
			return lowercasedDomainNameAppName;

		const kebabNormalizedGuess = getKebabNormalizedAppName(str);
		if (iconExists(kebabNormalizedGuess))
			return kebabNormalizedGuess;

		const undescoreToKebabGuess = getUndescoreToKebabAppName(str);
		if (iconExists(undescoreToKebabGuess))
			return undescoreToKebabGuess;

		const iconSearchResult = fuzzyQuery(str, preppedIcons);
		if (iconSearchResult && iconExists(iconSearchResult.icon))
			return iconSearchResult.icon;

		const nameSearchResult = root.fuzzyQuery(str, preppedNames);
		if (nameSearchResult && iconExists(nameSearchResult.icon))
			return nameSearchResult.icon;

		return "application-x-executable";
	}

	function iconExists(iconName) {
		if (!iconName || iconName.length == 0)
			return false;
		return (Quickshell.iconPath(iconName, true).length > 0) && !iconName.includes("image-missing");
	}
}
