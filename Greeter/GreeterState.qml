pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Greetd
import Quickshell.Io
import QtQuick

Scope {
	id: root

	property bool awaitingResponse: false
	property string buffer: ""
	property bool echoResponse: false
	property string errorMessage: ""
	property bool launching: false
	property string promptMessage: ""
	readonly property var selectedSession: sessionIndex >= 0 ? sessions[sessionIndex] : null
	property int sessionIndex: sessions.length > 0 ? 0 : -1
	property var sessions: []
	required property string username

	signal flashMsg

	function handleKey(event: KeyEvent): void {
		if (launching)
			return;

		if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
			submit();
			event.accepted = true;
			return;
		}

		if (event.key === Qt.Key_Backspace) {
			if (event.modifiers & Qt.ControlModifier)
				buffer = "";
			else
				buffer = buffer.slice(0, -1);

			event.accepted = true;
			return;
		}

		if (event.text && !/[\r\n]/.test(event.text)) {
			buffer += event.text;
			event.accepted = true;
		}
	}

	function launchSelected(): void {
		if (!selectedSession || !selectedSession.command || selectedSession.command.length === 0) {
			errorMessage = qsTr("No session selected.");
			flashMsg();
			launching = false;
			return;
		}

		launching = true;
		Greetd.launch(selectedSession.command, [], true);
	}

	function submit(): void {
		errorMessage = "";

		if (awaitingResponse) {
			Greetd.respond(buffer);
			buffer = "";
			awaitingResponse = false;
			return;
		}

		Greetd.createSession(username);
	}

	Process {
		id: sessionLister

		command: ["python3", Quickshell.shellDir + "/scripts/get-sessions"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				try {
					root.sessions = JSON.parse(text);

					if (root.sessions.length > 0 && root.sessionIndex < 0)
						root.sessionIndex = 0;
				} catch (e) {
					root.errorMessage = `Failed to parse sessions: ${e}`;
				}
			}
		}
	}

	Connections {
		function onAuthFailure(message): void {
			root.awaitingResponse = false;
			root.launching = false;
			root.buffer = "";
			root.errorMessage = message || qsTr("Authentication failed.");
			root.flashMsg();
		}

		function onAuthMessage(message, error, responseRequired, echoResponse): void {
			root.promptMessage = message;
			root.echoResponse = echoResponse;

			if (error) {
				root.errorMessage = message;
				root.flashMsg();
			}

			if (responseRequired) {
				// lets the existing “type password then press enter” UX still work
				if (root.buffer.length > 0) {
					Greetd.respond(root.buffer);
					root.buffer = "";
					root.awaitingResponse = false;
				} else {
					root.awaitingResponse = true;
				}
			} else {
				root.awaitingResponse = false;
			}
		}

		function onError(error): void {
			root.awaitingResponse = false;
			root.launching = false;
			root.errorMessage = error;
			root.flashMsg();
		}

		function onReadyToLaunch(): void {
			root.launchSelected();
		}

		target: Greetd
	}
}
