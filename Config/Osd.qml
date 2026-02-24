import Quickshell.Io

JsonObject {
	property bool allMonBrightness: false
	property bool enableBrightness: true
	property bool enableMicrophone: true
	property bool enabled: true
	property int hideDelay: 3000
	property Sizes sizes: Sizes {
	}

	component Sizes: JsonObject {
		property int sliderHeight: 150
		property int sliderWidth: 30
	}
}
