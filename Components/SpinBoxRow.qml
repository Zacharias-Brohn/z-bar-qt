import QtQuick
import QtQuick.Layouts
import qs.Config

CustomRect {
	id: root

	required property string label
	required property real max
	required property real min
	property var onValueModified: function (value) {}
	property real step: 1
	required property real value

	Layout.fillWidth: true
	color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)
	implicitHeight: row.implicitHeight + Appearance.padding.large * 2
	radius: Appearance.rounding.normal

	Behavior on implicitHeight {
		Anim {
		}
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.large
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.normal

		CustomText {
			Layout.fillWidth: true
			text: root.label
		}

		CustomSpinBox {
			max: root.max
			min: root.min
			step: root.step
			value: root.value

			onValueModified: value => {
				root.onValueModified(value);
			}
		}
	}
}
