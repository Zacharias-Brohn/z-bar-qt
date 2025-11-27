import Quickshell
import QtQuick

FloatingWindow {

    title: "terminal"

    Rectangle {
        id: root
        width: 480
        height: 320

        property int callsToUpdateMinimumWidth: 0
        property bool optimize: true

        property int currentTextModel: 0
        property var columnTexts: [
            ["Click on either", "rectangle above", "and note how the counter", "below updates", "significantly faster using the", "regular (non-optimized)", "implementation"],
            ["The width", "of this column", "is", "no wider than the", "widest item"],
            ["Note how using Qt.callLater()", "the minimum width is", "calculated a bare-minimum", "number", "of times"]
        ]

        Text {
            x: 20; y: 280
            text: "Times minimum width has been calculated: " + root.callsToUpdateMinimumWidth
        }

        Row {
            y: 25; spacing: 30; anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                width: 200; height:  50; color: "lightgreen"
                Text { text: "Optimized behavior\nusing Qt.callLater()"; anchors.centerIn: parent }
                MouseArea { anchors.fill: parent; onClicked: { root.optimize = true; root.currentTextModel++ } }
            }
            Rectangle {
                width: 200; height:  50; color: "lightblue"
                Text { text: "Regular behavior"; anchors.centerIn: parent}
                MouseArea { anchors.fill: parent; onClicked: { root.optimize = false; root.currentTextModel++ } }
            }
        }

        Column {
            id: column
            anchors.centerIn: parent

            onChildrenChanged: root.optimize ? Qt.callLater(updateMinimumWidth) : updateMinimumWidth()

            property int widestChild
            function updateMinimumWidth() {
                root.callsToUpdateMinimumWidth++
                var w = 0;
                for (var i in children) {
                    var child = children[i];
                    if (child.implicitWidth > w) {
                        w = child.implicitWidth;
                    }
                }

                widestChild = w;
            }

            Repeater {
                id: repeater
                model: root.columnTexts[root.currentTextModel%3]
                delegate: Text {
                    id: text
                    required property string modelData
                    required property int index
                    color: "white"
                    text: modelData
                    width: column.widestChild
                    horizontalAlignment: Text.Center
                    Rectangle { anchors.fill: parent; z: -1; color: text.index%2 ? "gray" : "darkgray" }
                }
            }
        }
    }
}
