import Quickshell.Io

JsonObject {
    property BgColors backgrounds: BgColors {}
	property string schemeType: "vibrant"

    component BgColors: JsonObject {
        property string hover: "#15ffffff"
    }
}
