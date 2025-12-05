import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

Scope {
	id: root

	required property WlSessionLock lock

	readonly property alias passwd: passwd
	property string lockMessage
	property string state
	property string fprintState
	property string buffer

	signal flashMsg

	function handleKey(event: KeyEvent): void {
		if (passwd.active || state === "max")
		return;

		if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
			passwd.start();
		} else if (event.key === Qt.Key_Backspace) {
			if ( event.modifiers & Qt.ControlModifier ) {
				buffer = "";
			} else {
				buffer = buffer.slice(0, -1);
			}
		} else if ( event.key === Qt.Key_Escape ) {
			buffer = "";
		} else if (" abcdefghijklmnopqrstuvwxyz1234567890`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?".includes(event.text.toLowerCase())) {
			buffer += event.text;
		}
	}

	PamContext {
		id: passwd

		config: "passwd"
		configDirectory: Quickshell.shellDir + "/assets/pam.d"

		onMessageChanged: {
			if ( message.startsWith( "The account is locked" ))
			root.lockMessage = message;
			else if ( root.lockMessage && message.endsWith( " left to unlock)" ))
			root.lockMessage += "\n" + message;
		}

		onResponseRequiredChanged: {
			if ( !responseRequired )
			return;

			respond(root.buffer);
			root.buffer = "";
		}

		onCompleted: res => {
			if (res === PamResult.Success)
			return root.lock.locked = false;

			if (res === PamResult.Error)
			root.state = "error";
			else if (res === PamResult.MaxTries)
			root.state = "max";
			else if (res === PamResult.Failed)
			root.state = "fail";

			root.flashMsg();
			stateReset.restart();
		}
	}

	Timer {
		id: stateReset

		interval: 4000
		onTriggered: {
			if (root.state !== "max")
			root.state = "";
		}
	}

	Connections {
		target: root.lock

		function onSecureChanged(): void {
			if (root.lock.secure) {
				root.buffer = "";
				root.state = "";
				root.fprintState = "";
				root.lockMessage = "";
			}
		}
	}
}
