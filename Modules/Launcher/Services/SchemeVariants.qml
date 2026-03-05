pragma Singleton

import Quickshell
import QtQuick
import qs.Modules.Launcher
import qs.Config
import qs.Helpers

Searcher {
	id: root

	function transformSearch(search: string): string {
		return search.slice(`${Config.launcher.actionPrefix}variant `.length);
	}

	useFuzzy: Config.launcher.useFuzzy.variants

	list: [
		Variant {
			description: qsTr("Maximum chroma at each tone.")
			icon: "sentiment_very_dissatisfied"
			name: qsTr("Vibrant")
			variant: "vibrant"
		},
		Variant {
			description: qsTr("Pastel palette with a low chroma.")
			icon: "android"
			name: qsTr("Tonal Spot")
			variant: "tonalspot"
		},
		Variant {
			description: qsTr("Hue-shifted, artistic or playful colors.")
			icon: "compare_arrows"
			name: qsTr("Expressive")
			variant: "expressive"
		},
		Variant {
			description: qsTr("Preserve source color exactly.")
			icon: "compare"
			name: qsTr("Fidelity")
			variant: "fidelity"
		},
		Variant {
			description: qsTr("Almost identical to fidelity.")
			icon: "sentiment_calm"
			name: qsTr("Content")
			variant: "content"
		},
		Variant {
			description: qsTr("The seed colour's hue does not appear in the theme.")
			icon: "nutrition"
			name: qsTr("Fruit Salad")
			variant: "fruit-salad"
		},
		Variant {
			description: qsTr("Like Fruit Salad but different hues.")
			icon: "looks"
			name: qsTr("Rainbow")
			variant: "rainbow"
		},
		Variant {
			description: qsTr("Close to grayscale, a hint of chroma.")
			icon: "contrast"
			name: qsTr("Neutral")
			variant: "neutral"
		},
		Variant {
			description: qsTr("All colours are grayscale, no chroma.")
			icon: "filter_b_and_w"
			name: qsTr("Monochrome")
			variant: "monochrome"
		}
	]

	component Variant: QtObject {
		required property string description
		required property string icon
		required property string name
		required property string variant

		function onClicked(list: AppList): void {
			list.visibilities.launcher = false;
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--scheme", variant]);
			Config.colors.schemeType = variant;
			Config.save();
		}
	}
}
