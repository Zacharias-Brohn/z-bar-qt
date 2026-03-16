import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	id: root

	required property string name

	Layout.preferredHeight: 60
	Layout.preferredWidth: 200

	CustomText {
		anchors.fill: parent
		font.bold: true
		font.pointSize: Appearance.font.size.large * 2
		text: root.name
		verticalAlignment: Text.AlignVCenter
	}
}
