import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	Layout.bottomMargin: dockRow.padding + Appearance.rounding.normal
	Layout.fillHeight: true
	Layout.topMargin: dockRow.padding + Appearance.rounding.normal
	color: DynamicColors.palette.m3outlineVariant
	implicitWidth: 1
}
