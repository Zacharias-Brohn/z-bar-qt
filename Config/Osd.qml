import Quickshell.Io

JsonObject {
    property bool enabled: true
    property int hideDelay: 3000
    property bool enableBrightness: true
    property bool enableMicrophone: true
	property bool allMonBrightness: false
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property int sliderWidth: 30
        property int sliderHeight: 150
    }
}
