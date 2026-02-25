import QtQuick

QtObject {
	property string activeIcon: icon
	property string activeText: text
	property string icon
	required property string text
	property string trailingIcon
	property var value

	signal clicked
}
