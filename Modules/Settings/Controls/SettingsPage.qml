import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

CustomFlickable {
	id: root

	default property alias contentData: clayout.data

	contentHeight: clayout.implicitHeight

	TapHandler {
		acceptedButtons: Qt.LeftButton

		onTapped: function (eventPoint) {
			const menu = SettingsDropdowns.activeMenu;
			if (!menu)
				return;

			const p = eventPoint.scenePosition;

			if (SettingsDropdowns.hit(SettingsDropdowns.activeTrigger, p))
				return;

			if (SettingsDropdowns.hit(menu, p))
				return;

			SettingsDropdowns.closeActive();
		}
	}

	ColumnLayout {
		id: clayout

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: Appearance.spacing.small
	}
}
