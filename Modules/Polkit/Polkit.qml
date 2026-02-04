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

		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		WlrLayershell.namespace: "ZShell-Auth"
        WlrLayershell.layer: WlrLayer.Overlay
		visible: false
		color: "transparent"
		property bool detailsOpen: false

		Connections {
			target: root

			onShouldShowChanged: {
				if ( root.shouldShow ) {
					panelWindow.visible = true
					openAnim.start()
				} else {
					closeAnim.start()
				}
			}
		}

		Anim {
			id: openAnim
			target: inputPanel
			property: "opacity"
			to: 1
			duration: MaterialEasing.expressiveEffectsTime
		}

		Anim {
			id: closeAnim
			target: inputPanel
			property: "opacity"
			to: 0
			duration: MaterialEasing.expressiveEffectsTime
			onStarted: {
				panelWindow.detailsOpen = false
			}
			onFinished: {
				panelWindow.visible = false
			}
		}

		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}

		// mask: Region { item: inputPanel }

		Rectangle {
			id: inputPanel

			color: DynamicColors.tPalette.m3surface
			opacity: 0

			anchors.centerIn: parent
			radius: 24

			implicitWidth: layout.childrenRect.width + 32
			implicitHeight: layout.childrenRect.height + 28
			ColumnLayout {
				id: layout
				anchors.centerIn: parent

				RowLayout {
					id: contentRow
					spacing: 24

					Item {
						Layout.preferredWidth: icon.implicitSize
						Layout.preferredHeight: icon.implicitSize
						Layout.leftMargin: 16
						Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
						IconImage {
							id: icon

							anchors.fill: parent
							visible: `${source}`.includes("://")

							source: Quickshell.iconPath(polkitAgent.flow?.iconName, true) ?? ""
							implicitSize: 64
							mipmap: true
						}

						MaterialIcon {
							visible: !icon.visible

							text: "security"
							anchors.fill: parent
							font.pointSize: 64
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
						}
					}

					ColumnLayout {
						id: contentColumn
						Layout.fillWidth: true
						Layout.fillHeight: true

						CustomText {
							Layout.preferredWidth: Math.min(600, contentWidth)
							Layout.alignment: Qt.AlignLeft

							text: polkitAgent.flow?.message
							wrapMode: Text.WordWrap
							font.pointSize: 16
							font.bold: true
						}

						CustomText {
							Layout.preferredWidth: Math.min(600, contentWidth)
							Layout.alignment: Qt.AlignLeft

							text: polkitAgent.flow?.supplementaryMessage || "No Additional Information"
							color: DynamicColors.tPalette.m3onSurfaceVariant
							wrapMode: Text.WordWrap
							font.pointSize: 12
							font.bold: true
						}

						TextField {
							id: passInput

							echoMode: polkitAgent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
							placeholderText: polkitAgent.flow?.failed ? " Incorrect Password" : " Input Password"
							selectByMouse: true
							onAccepted: okButton.clicked()

							placeholderTextColor: polkitAgent.flow?.failed ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurfaceVariant

							Layout.preferredWidth: contentColumn.implicitWidth
							Layout.preferredHeight: 40

							background: CustomRect {
								radius: 8
								implicitHeight: 40
								color: ( polkitAgent.flow?.failed && passInput.text === "" ) ? DynamicColors.palette.m3error : DynamicColors.tPalette.m3surfaceVariant
							}
						}

						CustomCheckbox {
							id: showPassCheckbox
							text: "Show Password"
							checked: polkitAgent.flow?.responseVisible
							onCheckedChanged: {
								passInput.echoMode = checked ? TextInput.Normal : TextInput.Password
								passInput.forceActiveFocus()
							}

							Layout.alignment: Qt.AlignLeft
						}
					}
				}

				CustomRect {
					id: detailsPanel

					visible: true
					color: DynamicColors.tPalette.m3surfaceContainerLow
					radius: 16
					clip: true
					implicitHeight: 0
					Layout.fillWidth: true
					Layout.preferredHeight: implicitHeight

					property bool open: panelWindow.detailsOpen

					Behavior on open {
						ParallelAnimation {
							Anim {
								target: detailsPanel

								property: "implicitHeight"
								to: !detailsPanel.open ? textDetailsColumn.childrenRect.height + 16 : 0
								duration: MaterialEasing.expressiveEffectsTime
							}

							Anim {
								target: textDetailsColumn

								property: "opacity"
								to: !detailsPanel.open ? 1 : 0
								duration: MaterialEasing.expressiveEffectsTime
							}

							Anim {
								target: textDetailsColumn

								property: "scale"
								to: !detailsPanel.open ? 1 : 0.9
								duration: MaterialEasing.expressiveEffectsTime
							}
						}
					}

					ColumnLayout {
						id: textDetailsColumn
						spacing: 8
						anchors.fill: parent
						anchors.margins: 8
						opacity: 0
						scale: 0.9

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
					spacing: 8
					Layout.preferredWidth: contentRow.implicitWidth

					CustomButton {
						id: detailsButton
						text: "Details"
						textColor: DynamicColors.palette.m3onSurface
						bgColor: DynamicColors.palette.m3surfaceContainer
						enabled: true
						radius: 1000

						Layout.preferredWidth: 92
						Layout.preferredHeight: 40
						Layout.alignment: Qt.AlignLeft

						onClicked: {
							panelWindow.detailsOpen = !panelWindow.detailsOpen
							console.log(panelWindow.detailsOpen)
						}
					}

					Item {
						id: spacer
						Layout.fillWidth: true
					}

					CustomButton {
						id: okButton
						text: "OK"
						textColor: DynamicColors.palette.m3onPrimary
						bgColor: DynamicColors.palette.m3primary
						enabled: passInput.text.length > 0 || !!polkitAgent.flow?.isResponseRequired
						radius: 1000
						Layout.preferredWidth: 76
						Layout.preferredHeight: 40
						Layout.alignment: Qt.AlignRight
						onClicked: {
							polkitAgent.flow.submit(passInput.text)
							passInput.text = ""
							passInput.forceActiveFocus()
						}
					}

					CustomButton {
						id: cancelButton
						text: "Cancel"
						textColor: DynamicColors.palette.m3onSurface
						bgColor: DynamicColors.palette.m3surfaceContainer
						enabled: passInput.text.length > 0 || !!polkitAgent.flow?.isResponseRequired
						radius: 1000
						Layout.preferredWidth: 76
						Layout.preferredHeight: 40
						Layout.alignment: Qt.AlignRight
						onClicked: {
							root.shouldShow = false
							console.log(icon.source, icon.visible)
							polkitAgent.flow.cancelAuthenticationRequest()
							passInput.text = ""
						}
					}
				}
			}
		}

		Connections {
			target: polkitAgent.flow

			function onIsResponseRequiredChanged() {
				passInput.text = ""
				if ( polkitAgent.flow?.isResponseRequired )
					root.shouldShow = true
					passInput.forceActiveFocus()
			}

			function onIsSuccessfulChanged() {
				if ( polkitAgent.flow?.isSuccessful )
					root.shouldShow = false
					passInput.text = ""
			}
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
			screen: modelData
			exclusionMode: ExclusionMode.Ignore
			visible: panelWindow.visible

			Behavior on color {
				CAnim {}
			}

			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
		}
	}
}
