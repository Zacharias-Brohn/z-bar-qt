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

		RowLayout {
			Layout.topMargin: 10
			spacing: 15
			Rectangle {
				Layout.preferredWidth: 40
				Layout.preferredHeight: 40
				Layout.alignment: Qt.AlignVCenter
				color: DynamicColors.tPalette.m3primaryContainer
				radius: 1000
				MaterialIcon {
					anchors.centerIn: parent
					color: DynamicColors.palette.m3onPrimaryContainer
					text: "volume_up"
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
						anchors.fill: parent
						value: Audio.volume
						onMoved: Audio.setVolume(value)

						Behavior on value { Anim {} }
					}
				}
			}
		}


		RowLayout {
			Layout.topMargin: 10
			spacing: 15
			Rectangle {
				Layout.preferredWidth: 40
				Layout.preferredHeight: 40
				Layout.alignment: Qt.AlignVCenter
				color: DynamicColors.tPalette.m3primaryContainer
				radius: 1000
				MaterialIcon {
					anchors.centerIn: parent
					anchors.alignWhenCentered: false
					color: DynamicColors.palette.m3onPrimaryContainer
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
						anchors.fill: parent
						value: Audio.sourceVolume
						onMoved: Audio.setSourceVolume(value)

						Behavior on value { Anim {} }
					}
				}
			}
		}

		Rectangle {
			Layout.topMargin: 10
			Layout.fillWidth: true
			Layout.preferredHeight: 1

			color: DynamicColors.tPalette.m3outline
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

                function isValidMatch(searchTerm, entry) {
					if (!entry)
						return false;
					var search = searchTerm.toLowerCase();
					var id = (entry.id || "").toLowerCase();
					var name = (entry.name || "").toLowerCase();
					var icon = (entry.icon || "").toLowerCase();
					// Match is valid if search term appears in entry or entry appears in search
					return id.includes(search) || name.includes(search) || icon.includes(search) || search.includes(id.split('.').pop()) || search.includes(name.replace(/\s+/g, ''));
                }

				readonly property string appName: {
					if (!modelData)
						return "Unknown App";

					var props = modelData.properties;
					var desc = modelData.description || "";
					var name = modelData.name || "";
					var mediaName = props["media.name"] || "";

					if ( mediaName !== "playStream" ) {
						return mediaName;
					}

					if (!props) {
						if (desc)
							return desc;
						if (name) {
							var nameParts = name.split(/[-_]/);
							if (nameParts.length > 0 && nameParts[0])
								return nameParts[0].charAt(0).toUpperCase() + nameParts[0].slice(1);
							return name;
						}
						return "Unknown App";
					}

					var binaryName = props["application.process.binary"] || "";

					// Try binary name first (fixes Electron apps like vesktop)
					if (binaryName) {
						var binParts = binaryName.split("/");
						if (binParts.length > 0) {
							var binName = binParts[binParts.length - 1].toLowerCase();
							var entry = ThemeIcons.findAppEntry(binName);
							// Only use entry if it's actually related to binary name
							if (entry && entry.name && isValidMatch(binName, entry))
								return entry.name;
						}
					}

					var computedAppName = props["application.name"] || "";
					var mediaName = props["media.name"] || "";
					var appId = props["application.id"] || "";

					if (appId) {
						var entry = ThemeIcons.findAppEntry(appId);
						if (entry && entry.name && isValidMatch(appId, entry))
							return entry.name;
						if (!computedAppName) {
							var parts = appId.split(".");
							if (parts.length > 0 && parts[0])
								computedAppName = parts[0].charAt(0).toUpperCase() + parts[0].slice(1);
						}
					}

					if (!computedAppName && binaryName) {
						var binParts = binaryName.split("/");
						if (binParts.length > 0 && binParts[binParts.length - 1])
							computedAppName = binParts[binParts.length - 1].charAt(0).toUpperCase() + binParts[binParts.length - 1].slice(1);
					}

					var result = computedAppName || mediaTitle || mediaName || binaryName || desc || name;

					if (!result || result === "" || result === "Unknown App") {
						if (name) {
							var nameParts = name.split(/[-_]/);
							if (nameParts.length > 0 && nameParts[0])
								result = nameParts[0].charAt(0).toUpperCase() + nameParts[0].slice(1);
						}
					}

					return result || "Unknown App";
				}

				PwObjectTracker {
					objects: appBox.modelData ? [appBox.modelData] : []
				}

				PwNodePeakMonitor {
					id: peak
					node: appBox.modelData
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
						id: icon
						property string iconPath1: Quickshell.iconPath(DesktopEntries.byId(appBox.modelData.name).icon);
						property string iconPath2: Quickshell.iconPath(DesktopEntries.byId(appBox.appName).icon);
						source: iconPath1 !== "" ? iconPath1 : iconPath2
						Layout.alignment: Qt.AlignVCenter
						implicitSize: 42

						StateLayer {
							radius: 1000
							onClicked: {
								appBox.modelData.audio.muted = !appBox.modelData.audio.muted;
							}
						}
					}

					ColumnLayout {
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						Layout.fillHeight: true

						TextMetrics {
							id: metrics
							text: appBox.appName
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
							Layout.bottomMargin: 5
							implicitHeight: 10
							CustomAudioSlider {
								anchors.fill: parent
								value: appBox.modelData.audio.volume
								peak: peak.peak
								onMoved: {
									Audio.setAppAudioVolume(appBox.modelData, value)
									console.log(icon.iconPath1, icon.iconPath2)
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
