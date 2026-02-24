pragma ComponentBehavior: Bound

import ZShell
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs.Components
import qs.Config
import qs.Helpers

MouseArea {
	id: root

	property list<var> clients: {
		const mon = Hypr.monitorFor(screen);
		if (!mon)
			return [];

		const special = mon.lastIpcObject.specialWorkspace;
		const wsId = special.name ? special.id : mon.activeWorkspace.id;

		return Hypr.toplevels.values.filter(c => c.workspace?.id === wsId).sort((a, b) => {
			const ac = a.lastIpcObject;
			const bc = b.lastIpcObject;
			return (bc.pinned - ac.pinned) || ((bc.fullscreen !== 0) - (ac.fullscreen !== 0)) || (bc.floating - ac.floating);
		});
	}
	property real ex: screen.width
	property real ey: screen.height
	required property LazyLoader loader
	property bool onClient
	property real realBorderWidth: onClient ? (Hypr.options["general:border_size"] ?? 1) : 2
	property real realRounding: onClient ? (Hypr.options["decoration:rounding"] ?? 0) : 0
	property real rsx: Math.min(sx, ex)
	property real rsy: Math.min(sy, ey)
	required property ShellScreen screen
	property real sh: Math.abs(sy - ey)
	property real ssx
	property real ssy
	property real sw: Math.abs(sx - ex)
	property real sx: 0
	property real sy: 0

	function checkClientRects(x: real, y: real): void {
		for (const client of clients) {
			if (!client)
				continue;

			let {
				at: [cx, cy],
				size: [cw, ch]
			} = client.lastIpcObject;
			cx -= screen.x;
			cy -= screen.y;
			if (cx <= x && cy <= y && cx + cw >= x && cy + ch >= y) {
				onClient = true;
				sx = cx;
				sy = cy;
				ex = cx + cw;
				ey = cy + ch;
				break;
			}
		}
	}

	function save(): void {
		const tmpfile = Qt.resolvedUrl(`/tmp/zshell-picker-${Quickshell.processId}-${Date.now()}.png`);
		ZShellIo.saveItem(screencopy, tmpfile, Qt.rect(Math.ceil(rsx), Math.ceil(rsy), Math.floor(sw), Math.floor(sh)), path => Quickshell.execDetached(["swappy", "-f", path]));
		closeAnim.start();
	}

	anchors.fill: parent
	cursorShape: Qt.CrossCursor
	focus: true
	hoverEnabled: true
	opacity: 0

	Behavior on opacity {
		Anim {
			duration: 300
		}
	}
	Behavior on rsx {
		enabled: !root.pressed

		ExAnim {
		}
	}
	Behavior on rsy {
		enabled: !root.pressed

		ExAnim {
		}
	}
	Behavior on sh {
		enabled: !root.pressed

		ExAnim {
		}
	}
	Behavior on sw {
		enabled: !root.pressed

		ExAnim {
		}
	}

	Component.onCompleted: {
		Hypr.extras.refreshOptions();
		if (loader.freeze)
			clients = clients;

		opacity = 1;

		const c = clients[0];
		if (c) {
			const cx = c.lastIpcObject.at[0] - screen.x;
			const cy = c.lastIpcObject.at[1] - screen.y;
			onClient = true;
			sx = cx;
			sy = cy;
			ex = cx + c.lastIpcObject.size[0];
			ey = cy + c.lastIpcObject.size[1];
		} else {
			sx = screen.width / 2 - 100;
			sy = screen.height / 2 - 100;
			ex = screen.width / 2 + 100;
			ey = screen.height / 2 + 100;
		}
	}
	Keys.onEscapePressed: closeAnim.start()
	onClientsChanged: checkClientRects(mouseX, mouseY)
	onPositionChanged: event => {
		const x = event.x;
		const y = event.y;

		if (pressed) {
			onClient = false;
			sx = ssx;
			sy = ssy;
			ex = x;
			ey = y;
		} else {
			checkClientRects(x, y);
		}
	}
	onPressed: event => {
		ssx = event.x;
		ssy = event.y;
	}
	onReleased: {
		if (closeAnim.running)
			return;

		if (root.loader.freeze) {
			save();
		} else {
			overlay.visible = border.visible = false;
			screencopy.visible = false;
			screencopy.active = true;
		}
	}

	SequentialAnimation {
		id: closeAnim

		PropertyAction {
			property: "closing"
			target: root.loader
			value: true
		}

		ParallelAnimation {
			Anim {
				duration: 300
				property: "opacity"
				target: root
				to: 0
			}

			ExAnim {
				properties: "rsx,rsy"
				target: root
				to: 0
			}

			ExAnim {
				property: "sw"
				target: root
				to: root.screen.width
			}

			ExAnim {
				property: "sh"
				target: root
				to: root.screen.height
			}
		}

		PropertyAction {
			property: "activeAsync"
			target: root.loader
			value: false
		}
	}

	Loader {
		id: screencopy

		active: root.loader.freeze
		anchors.fill: parent
		asynchronous: true

		sourceComponent: ScreencopyView {
			captureSource: root.screen
			paintCursor: false

			onHasContentChanged: {
				if (hasContent && !root.loader.freeze) {
					overlay.visible = border.visible = true;
					root.save();
				}
			}
		}
	}

	Rectangle {
		id: overlay

		anchors.fill: parent
		color: "white"
		layer.enabled: true
		opacity: 0.3
		radius: root.realRounding

		layer.effect: MultiEffect {
			maskEnabled: true
			maskInverted: true
			maskSource: selectionWrapper
			maskSpreadAtMin: 1
			maskThresholdMin: 0.5
		}
	}

	Item {
		id: selectionWrapper

		anchors.fill: parent
		layer.enabled: true
		visible: false

		Rectangle {
			id: selectionRect

			implicitHeight: root.sh
			implicitWidth: root.sw
			radius: root.realRounding
			x: root.rsx
			y: root.rsy
		}
	}

	Rectangle {
		id: border

		border.color: DynamicColors.palette.m3primary
		border.width: root.realBorderWidth
		color: "transparent"
		implicitHeight: selectionRect.implicitHeight + root.realBorderWidth * 2
		implicitWidth: selectionRect.implicitWidth + root.realBorderWidth * 2
		radius: root.realRounding > 0 ? root.realRounding + root.realBorderWidth : 0
		x: selectionRect.x - root.realBorderWidth
		y: selectionRect.y - root.realBorderWidth

		Behavior on border.color {
			Anim {
			}
		}
	}

	component ExAnim: Anim {
		duration: MaterialEasing.expressiveEffectsTime
		easing.bezierCurve: MaterialEasing.expressiveEffects
	}
}
