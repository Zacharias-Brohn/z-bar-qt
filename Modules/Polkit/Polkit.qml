import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Components
import qs.Modules
import qs.Config

Scope {
	id: root

	property alias polkitAgent: polkitAgent
	property bool shouldShow: false

	PanelWindow {
		id: panelWindow

		property bool detailsOpen: false

		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "ZShell-Auth"
		color: "transparent"
		visible: false

		Connections {
			target: root

			onShouldShowChanged: {
				if (root.shouldShow) {
					panelWindow.visible = true;
					openAnim.start();
				} else {
					closeAnim.start();
				}
			}
		}

		Anim {
			id: openAnim

			duration: MaterialEasing.expressiveEffectsTime
			property: "opacity"
			target: inputPanel
			to: 1
		}

		Anim {
			id: closeAnim

			duration: MaterialEasing.expressiveEffectsTime
			property: "opacity"
			target: inputPanel
			to: 0

			onFinished: {
				panelWindow.visible = false;
			}
			onStarted: {
				panelWindow.detailsOpen = false;
			}
		}

		anchors {
			bottom: true
			left: true
			right: true
			top: true
		}

		// mask: Region { item: inputPanel }

		Rectangle {
			id: inputPanel

			anchors.centerIn: parent
			color: DynamicColors.tPalette.m3surface
			implicitHeight: layout.childrenRect.height + 28
			implicitWidth: layout.childrenRect.width + 32
			opacity: 0
			radius: 24

			ColumnLayout {
				id: layout

				anchors.centerIn: parent

				RowLayout {
					id: contentRow

					spacing: 24

					Item {
						Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
						Layout.leftMargin: 16
						Layout.preferredHeight: icon.implicitSize
						Layout.preferredWidth: icon.implicitSize

						IconImage {
							id: icon

							anchors.fill: parent
							implicitSize: 64
							mipmap: true
							source: Quickshell.iconPath(polkitAgent.flow?.iconName, true) ?? ""
							visible: `${source}`.includes("://")
						}

						MaterialIcon {
							anchors.fill: parent
							font.pointSize: 64
							horizontalAlignment: Text.AlignHCenter
							text: "security"
							verticalAlignment: Text.AlignVCenter
							visible: !icon.visible
						}
					}

					ColumnLayout {
						id: contentColumn

						Layout.fillHeight: true
						Layout.fillWidth: true

						CustomText {
							Layout.alignment: Qt.AlignLeft
							Layout.preferredWidth: Math.min(600, contentWidth)
							font.bold: true
							font.pointSize: 16
							text: polkitAgent.flow?.message
							wrapMode: Text.WordWrap
						}

						CustomText {
							Layout.alignment: Qt.AlignLeft
							Layout.preferredWidth: Math.min(600, contentWidth)
							color: DynamicColors.tPalette.m3onSurfaceVariant
							font.bold: true
							font.pointSize: 12
							text: polkitAgent.flow?.supplementaryMessage || "No Additional Information"
							wrapMode: Text.WordWrap
						}

						TextField {
							id: passInput

							Layout.preferredHeight: 40
							Layout.preferredWidth: contentColumn.implicitWidth
							color: DynamicColors.palette.m3onSurfaceVariant
							echoMode: polkitAgent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
							placeholderText: polkitAgent.flow?.failed ? " Incorrect Password" : " Input Password"
							placeholderTextColor: polkitAgent.flow?.failed ? DynamicColors.palette.m3onError : DynamicColors.tPalette.m3onSurfaceVariant
							selectByMouse: true

							background: CustomRect {
								color: (polkitAgent.flow?.failed && passInput.text === "") ? DynamicColors.palette.m3error : DynamicColors.tPalette.m3surfaceVariant
								implicitHeight: 40
								radius: 8
							}

							onAccepted: okButton.clicked()
						}

						CustomCheckbox {
							id: showPassCheckbox

							Layout.alignment: Qt.AlignLeft
							checked: polkitAgent.flow?.responseVisible
							text: "Show Password"

							onCheckedChanged: {
								passInput.echoMode = checked ? TextInput.Normal : TextInput.Password;
								passInput.forceActiveFocus();
							}
						}
					}
				}

				CustomRect {
					id: detailsPanel

					property bool open: panelWindow.detailsOpen

					Layout.fillWidth: true
					Layout.preferredHeight: implicitHeight
					clip: true
					color: DynamicColors.tPalette.m3surfaceContainerLow
					implicitHeight: 0
					radius: 16
					visible: true

					Behavior on open {
						ParallelAnimation {
							Anim {
								duration: MaterialEasing.expressiveEffectsTime
								property: "implicitHeight"
								target: detailsPanel
								to: !detailsPanel.open ? textDetailsColumn.childrenRect.height + 16 : 0
							}

							Anim {
								duration: MaterialEasing.expressiveEffectsTime
								property: "opacity"
								target: textDetailsColumn
								to: !detailsPanel.open ? 1 : 0
							}

							Anim {
								duration: MaterialEasing.expressiveEffectsTime
								property: "scale"
								target: textDetailsColumn
								to: !detailsPanel.open ? 1 : 0.9
							}
						}
					}

					ColumnLayout {
						id: textDetailsColumn

						anchors.fill: parent
						anchors.margins: 8
						opacity: 0
						scale: 0.9
						spacing: 8

						CustomText {
							text: `actionId: ${polkitAgent.flow?.actionId}`
							wrapMode: Text.WordWrap
						}

						CustomText {
							text: `selectedIdentity: ${polkitAgent.flow?.selectedIdentity}`
							wrapMode: Text.WordWrap
						}
					}
				}

				RowLayout {
					Layout.preferredWidth: contentRow.implicitWidth
					spacing: 8

					CustomButton {
						id: detailsButton

						Layout.alignment: Qt.AlignLeft
						Layout.preferredHeight: 40
						Layout.preferredWidth: 92
						bgColor: DynamicColors.palette.m3surfaceContainer
						enabled: true
						radius: 1000
						text: "Details"
						textColor: DynamicColors.palette.m3onSurface

						onClicked: {
							panelWindow.detailsOpen = !panelWindow.detailsOpen;
						}
					}

					Item {
						id: spacer

						Layout.fillWidth: true
					}

					CustomButton {
						id: okButton

						Layout.alignment: Qt.AlignRight
						Layout.preferredHeight: 40
						Layout.preferredWidth: 76
						bgColor: DynamicColors.palette.m3primary
						enabled: passInput.text.length > 0 || !!polkitAgent.flow?.isResponseRequired
						radius: 1000
						text: "OK"
						textColor: DynamicColors.palette.m3onPrimary

						onClicked: {
							polkitAgent.flow.submit(passInput.text);
							passInput.text = "";
							passInput.forceActiveFocus();
						}
					}

					CustomButton {
						id: cancelButton

						Layout.alignment: Qt.AlignRight
						Layout.preferredHeight: 40
						Layout.preferredWidth: 76
						bgColor: DynamicColors.palette.m3surfaceContainer
						enabled: passInput.text.length > 0 || !!polkitAgent.flow?.isResponseRequired
						radius: 1000
						text: "Cancel"
						textColor: DynamicColors.palette.m3onSurface

						onClicked: {
							root.shouldShow = false;
							polkitAgent.flow.cancelAuthenticationRequest();
							passInput.text = "";
						}
					}
				}
			}
		}

		Connections {
			function onIsResponseRequiredChanged() {
				passInput.text = "";
				if (polkitAgent.flow?.isResponseRequired)
					root.shouldShow = true;
				passInput.forceActiveFocus();
			}

			function onIsSuccessfulChanged() {
				if (polkitAgent.flow?.isSuccessful)
					root.shouldShow = false;
				passInput.text = "";
			}

			target: polkitAgent.flow
		}
	}

	PolkitAgent {
		id: polkitAgent

	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData

			color: root.shouldShow ? "#80000000" : "transparent"
			exclusionMode: ExclusionMode.Ignore
			screen: modelData
			visible: panelWindow.visible

			Behavior on color {
				CAnim {
				}
			}

			anchors {
				bottom: true
				left: true
				right: true
				top: true
			}
		}
	}
}
