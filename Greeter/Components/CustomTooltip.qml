import QtQuick
import QtQuick.Controls
import qs.Components

ToolTip {
	id: root

	property bool alternativeVisibleCondition: false
	property bool extraVisibleCondition: true
	readonly property bool internalVisibleCondition: (extraVisibleCondition && (parent.hovered === undefined || parent?.hovered)) || alternativeVisibleCondition

	background: null
	horizontalPadding: 10
	verticalPadding: 5
	visible: internalVisibleCondition

	contentItem: CustomTooltipContent {
		id: contentItem

		horizontalPadding: root.horizontalPadding
		shown: root.internalVisibleCondition
		text: root.text
		verticalPadding: root.verticalPadding
	}
}
