import QtQuick

QtObject {
	id: root

	property real idx1: index
	property int idx1Duration: 100
	property real idx2: index
	property int idx2Duration: 300
	required property int index

	Behavior on idx1 {
		NumberAnimation {
			duration: root.idx1Duration
			easing.type: Easing.OutSine
		}
	}
	Behavior on idx2 {
		NumberAnimation {
			duration: root.idx2Duration
			easing.type: Easing.OutSine
		}
	}
}
