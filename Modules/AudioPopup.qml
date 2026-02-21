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
import qs.Helpers

Item {
    id: root

    implicitWidth: layout.implicitWidth + 5 * 2
    implicitHeight: layout.implicitHeight + 5 * 2

	readonly property int topMargin: 0
	readonly property int rounding: 6

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

				color: stack.currentIndex === 0 ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer

				StateLayer {

					function onClicked(): void {
						stack.currentIndex = 0;
					}

					CustomText {
						text: qsTr("Volumes")
						anchors.centerIn: parent
						color: stack.currentIndex === 0 ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3primary
					}
				}
			}

			CustomClippingRect {
				radius: 6
				Layout.fillWidth: true
				Layout.preferredHeight: tabBar.tabHeight

				color: stack.currentIndex === 1 ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer

				StateLayer {

					function onClicked(): void {
						stack.currentIndex = 1;
					}

					CustomText {
						text: qsTr("Devices")
						anchors.centerIn: parent
						color: stack.currentIndex === 1 ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3primary
					}
				}
			}
		}

		StackLayout {
			id: stack
			Layout.fillWidth: true
			Layout.preferredHeight: currentIndex === 0 ? vol.childrenRect.height : dev.childrenRect.height
			currentIndex: 0

			VolumesTab { id: vol }
			DevicesTab { id: dev }

			Behavior on currentIndex {
				SequentialAnimation {
					ParallelAnimation {
						Anim {
							target: stack
							property: "opacity"
							to: 0
							duration: MaterialEasing.expressiveEffectsTime
						}

						Anim {
							target: stack
							property: "scale"
							to: 0.9
							duration: MaterialEasing.expressiveEffectsTime
						}
					}

					PropertyAction {}

					ParallelAnimation {
						Anim {
							target: stack
							property: "opacity"
							to: 1
							duration: MaterialEasing.expressiveEffectsTime
						}

						Anim {
							target: stack
							property: "scale"
							to: 1
							duration: MaterialEasing.expressiveEffectsTime
						}
					}
				}
			}
		}
    }

	component VolumesTab: ColumnLayout {
		spacing: 12

		CustomRect {
			Layout.topMargin: root.topMargin
			Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
			Layout.fillWidth: true
			color: DynamicColors.tPalette.m3surfaceContainer

			radius: root.rounding

			RowLayout {
				id: outputVolume
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.margins: Appearance.spacing.smaller
				spacing: 15
				CustomRect {
					Layout.preferredWidth: 40
					Layout.preferredHeight: 40
					Layout.alignment: Qt.AlignVCenter
					color: DynamicColors.palette.m3primary
					radius: 1000
					MaterialIcon {
						anchors.centerIn: parent
						color: DynamicColors.palette.m3onPrimary
						text: "speaker"
						font.pointSize: 22
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					RowLayout {
						Layout.fillWidth: true

						CustomText {
							text: "Output Volume"
							Layout.fillWidth: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						}

						CustomText {
							text: qsTr("%1").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`);
							font.bold: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
						}
					}

					CustomMouseArea {
						Layout.fillWidth: true
						Layout.preferredHeight: 10
						Layout.bottomMargin: 5

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							implicitHeight: 10
							value: Audio.volume
							onMoved: Audio.setVolume(value)

							Behavior on value { Anim {} }
						}
					}
				}
			}
		}


		CustomRect {
			Layout.topMargin: root.topMargin
			Layout.fillWidth: true
			Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
			color: DynamicColors.tPalette.m3surfaceContainer

			radius: root.rounding

			RowLayout {
				id: inputVolume
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.margins: Appearance.spacing.smaller
				spacing: 15
				Rectangle {
					Layout.preferredWidth: 40
					Layout.preferredHeight: 40
					Layout.alignment: Qt.AlignVCenter
					color: DynamicColors.palette.m3primary
					radius: 1000
					MaterialIcon {
						anchors.centerIn: parent
						anchors.alignWhenCentered: false
						color: DynamicColors.palette.m3onPrimary
						text: "mic"
						font.pointSize: 22
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					RowLayout {
						Layout.fillWidth: true
						Layout.fillHeight: true

						CustomText {
							text: "Input Volume"
							Layout.fillWidth: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						}

						CustomText {
							text: qsTr("%1").arg(Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`);
							font.bold: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
						}
					}

					CustomMouseArea {
						Layout.fillWidth: true
						Layout.bottomMargin: 5
						implicitHeight: 10

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							implicitHeight: 10
							value: Audio.sourceVolume
							onMoved: Audio.setSourceVolume(value)

							Behavior on value { Anim {} }
						}
					}
				}
			}
		}

		Rectangle {
			Layout.topMargin: root.topMargin
			Layout.fillWidth: true
			Layout.preferredHeight: 1

			color: DynamicColors.tPalette.m3outline
		}

		Repeater {
			model: Audio.streams.filter(s => s.isSink)

			CustomRect {
				id: appBox

				Layout.topMargin: root.topMargin
				Layout.fillWidth: true
				Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
				color: DynamicColors.tPalette.m3surfaceContainer

				radius: root.rounding


				required property var modelData
				required property int index

				RowLayout {
					id: layoutVolume
					anchors.fill: parent
					anchors.margins: Appearance.spacing.smaller
					spacing: 15


					CustomRect {
						Layout.preferredWidth: 40
						Layout.preferredHeight: 40
						Layout.alignment: Qt.AlignVCenter
						color: DynamicColors.palette.m3primary
						radius: 1000
						MaterialIcon {
							id: icon
							anchors.centerIn: parent
							text: "volume_up"
							font.pointSize: 22
							color: DynamicColors.palette.m3onPrimary

							StateLayer {
								radius: 1000
								onClicked: {
									appBox.modelData.audio.muted = !appBox.modelData.audio.muted;
								}
							}
						}
					}

					ColumnLayout {
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						Layout.fillHeight: true

						TextMetrics {
							id: metrics
							text: Audio.getStreamName(appBox.modelData)
							elide: Text.ElideRight
							elideWidth: root.width - 50
						}

						RowLayout {
							Layout.fillWidth: true
							Layout.fillHeight: true
							CustomText {
								text: metrics.elidedText
								elide: Text.ElideRight
								Layout.fillWidth: true
								Layout.fillHeight: true
								Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
							}

							CustomText {
								text: qsTr("%1").arg(appBox.modelData.audio.muted ? qsTr("Muted") : `${Math.round(appBox.modelData.audio.volume * 100)}%`);
								font.bold: true
								Layout.fillHeight: true
								Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
							}
						}

						CustomMouseArea {
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
							implicitHeight: 10
							CustomSlider {
								anchors.left: parent.left
								anchors.right: parent.right
								implicitHeight: 10
								value: appBox.modelData.audio.volume
								onMoved: {
									Audio.setStreamVolume(appBox.modelData, value)
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
