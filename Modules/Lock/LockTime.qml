import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Config

RowLayout {
	id: root

	property list<string> time: Time.longTime.split("")

	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		animate: true

		text: root.time[0]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		animate: true

		text: root.time[1]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		Layout.bottomMargin: 8
		animate: true

		text: root.time[2]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		animate: true

		text: root.time[3]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		animate: true

		text: root.time[4]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		Layout.bottomMargin: 8
		animate: true

		text: root.time[5]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		animate: true

		text: root.time[6]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
	CustomText {
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		animate: true

		text: root.time[7]
		font.pixelSize: 64
		font.weight: Font.Normal
		font.letterSpacing: 0.5
		color: DynamicColors.palette.m3onSurface
	}
}
