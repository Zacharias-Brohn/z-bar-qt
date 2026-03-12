import QtQuick
import QtQuick.Controls
import qs.Config

TextInput {
	renderType: Text.NativeRendering
	selectedTextColor: DynamicColors.palette.m3onSecondaryContainer
	selectionColor: DynamicColors.tPalette.colSecondaryContainer

	font {
		family: Appearance?.font.family.sans ?? "sans-serif"
		hintingPreference: Font.PreferFullHinting
		pixelSize: Appearance?.font.size.normal ?? 15
	}
}
