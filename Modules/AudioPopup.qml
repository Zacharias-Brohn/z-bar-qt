pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Config
import qs.Components
import qs.Daemons

Item {
    id: root

    implicitWidth: layout.implicitWidth + 10 * 2
    implicitHeight: layout.implicitHeight + 10 * 2

    required property var wrapper

    ColumnLayout {
        id: layout

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
		implicitWidth: stack.currentItem ? stack.currentItem.childrenRect.height : 0
		spacing: 12

		RowLayout {
			id: tabBar
			spacing: 6
			Layout.fillWidth: true
			property int tabHeight: 36

			CustomClippingRect {
				radius: 6
				Layout.fillWidth: true
				Layout.preferredHeight: tabBar.tabHeight

				color: stack.currentIndex === 0 ? DynamicColors.tPalette.m3primaryContainer : "transparent"

				StateLayer {

					function onClicked(): void {
						stack.currentIndex = 0;
					}

					CustomText {
						text: qsTr("Volumes")
						anchors.centerIn: parent
					}
				}
			}

			CustomClippingRect {
				radius: 6
				Layout.fillWidth: true
				Layout.preferredHeight: tabBar.tabHeight

				color: stack.currentIndex === 1 ? DynamicColors.tPalette.m3primaryContainer : "transparent"

				StateLayer {

					function onClicked(): void {
						stack.currentIndex = 1;
					}

					CustomText {
						text: qsTr("Devices")
						anchors.centerIn: parent
					}
				}
			}
		}

		StackLayout {
			id: stack
			Layout.fillWidth: true
			currentIndex: 0

			VolumesTab {}
			DevicesTab {}
		}
    }

	component VolumesTab: ColumnLayout {
		spacing: 12

		CustomText {
			text: qsTr("Output Volume (%1)")
				.arg(Audio.muted
					 ? qsTr("Muted")
					 : `${Math.round(Audio.volume * 100)}%`)
			font.weight: 500
		}

		CustomMouseArea {
			Layout.fillWidth: true
			implicitHeight: 10

			CustomSlider {
				anchors.fill: parent
				value: Audio.volume
				onMoved: Audio.setVolume(value)

				Behavior on value { Anim {} }
			}
		}

		CustomText {
			Layout.topMargin: 10
			text: qsTr("Input Volume (%1)")
				.arg(Audio.sourceMuted
					 ? qsTr("Muted")
					 : `${Math.round(Audio.sourceVolume * 100)}%`)
			font.weight: 500
		}

		CustomMouseArea {
			Layout.fillWidth: true
			implicitHeight: 10

			CustomSlider {
				anchors.fill: parent
				value: Audio.sourceVolume
				onMoved: Audio.setSourceVolume(value)

				Behavior on value { Anim {} }
			}
		}

		Repeater {
			model: Audio.appStreams

			Item {
				id: appBox

				Layout.topMargin: 10
				Layout.fillWidth: true
				Layout.preferredHeight: 42
				visible: !isCaptureStream
				required property PwNode modelData

				PwObjectTracker {
					objects: appBox.modelData ? [appBox.modelData] : []
				}

				readonly property bool isCaptureStream: {
					if (!modelData || !modelData.properties)
						return false;
					const props = modelData.properties;
					// Exclude capture streams - check for stream.capture.sink property
					if (props["stream.capture.sink"] !== undefined) {
						return true;
					}
					const mediaClass = props["media.class"] || "";
					// Exclude Stream/Input (capture) but allow Stream/Output (playback)
					if (mediaClass.includes("Capture") || mediaClass === "Stream/Input" || mediaClass === "Stream/Input/Audio") {
						return true;
					}
					const mediaRole = props["media.role"] || "";
					if (mediaRole === "Capture") {
						return true;
					}
					return false;
				}

				RowLayout {
					id: layoutVolume
					anchors.fill: parent
					spacing: 15

					IconImage {
						property string iconPath: Quickshell.iconPath(DesktopEntries.byId(appBox.modelData.name).icon)
						source: iconPath !== "" ? iconPath : Quickshell.iconPath("application-x-executable")
						Layout.alignment: Qt.AlignVCenter
						implicitSize: 42
					}

					ColumnLayout {
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						Layout.fillHeight: true

						TextMetrics {
							id: metrics
							text: appBox.modelData.properties["media.name"]
							elide: Text.ElideRight
							elideWidth: root.width - 50
						}

						CustomText {
							text: metrics.elidedText
							elide: Text.ElideRight
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						}

						CustomMouseArea {
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
							Layout.bottomMargin: 5
							implicitHeight: 10
							CustomSlider {
								anchors.fill: parent
								value: appBox.modelData.audio.volume
								onMoved: {
									Audio.setAppAudioVolume(appBox.modelData, value)
									console.log(layoutVolume.implicitHeight)
								}
							}
						}
					}
				}
			}
		}
	}

	component DevicesTab: ColumnLayout {
		spacing: 12

		ButtonGroup { id: sinks }
		ButtonGroup { id: sources }

		CustomText {
			text: qsTr("Output device")
			font.weight: 500
		}

		Repeater {
			model: Audio.sinks

			CustomRadioButton {
				required property PwNode modelData

				ButtonGroup.group: sinks
				checked: Audio.sink?.id === modelData.id
				onClicked: Audio.setAudioSink(modelData)
				text: modelData.description
			}
		}

		CustomText {
			Layout.topMargin: 10
			text: qsTr("Input device")
			font.weight: 500
		}

		Repeater {
			model: Audio.sources

			CustomRadioButton {
				required property PwNode modelData

				ButtonGroup.group: sources
				checked: Audio.source?.id === modelData.id
				onClicked: Audio.setAudioSource(modelData)
				text: modelData.description
			}
		}
	}
}
