import Quickshell.Io

JsonObject {
	property int blurAmount: 40
	property bool enableFprint: true
	property int maxFprintTries: 3
	property bool recolorLogo: false
	property Sizes sizes: Sizes {
	}

	component Sizes: JsonObject {
		property int centerWidth: 600
		property real heightMult: 0.7
		property real ratio: 16 / 9
	}
}
