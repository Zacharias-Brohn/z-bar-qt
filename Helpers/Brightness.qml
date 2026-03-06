pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.Config
import qs.Components

Singleton {
	id: root

	property bool appleDisplayPresent: false
	property list<var> ddcMonitors: []
	property list<var> ddcServiceMon: []
	readonly property list<Monitor> monitors: variants.instances

	function decreaseBrightness(): void {
		const monitor = getMonitor("active");
		if (monitor)
			monitor.setBrightness(monitor.brightness - Config.services.brightnessIncrement);
	}

	function getMonitor(query: string): var {
		if (query === "active") {
			return monitors.find(m => Hypr.monitorFor(m.modelData)?.focused);
		}

		if (query.startsWith("model:")) {
			const model = query.slice(6);
			return monitors.find(m => m.modelData.model === model);
		}

		if (query.startsWith("serial:")) {
			const serial = query.slice(7);
			return monitors.find(m => m.modelData.serialNumber === serial);
		}

		if (query.startsWith("id:")) {
			const id = parseInt(query.slice(3), 10);
			return monitors.find(m => Hypr.monitorFor(m.modelData)?.id === id);
		}

		return monitors.find(m => m.modelData.name === query);
	}

	function getMonitorForScreen(screen: ShellScreen): var {
		return monitors.find(m => m.modelData === screen);
	}

	function increaseBrightness(): void {
		const monitor = getMonitor("active");
		if (monitor)
			monitor.setBrightness(monitor.brightness + Config.services.brightnessIncrement);
	}

	onMonitorsChanged: {
		ddcMonitors = [];
		ddcServiceMon = [];
		ddcServiceProc.running = true;
		ddcProc.running = true;
	}

	Variants {
		id: variants

		model: Quickshell.screens

		Monitor {
		}
	}

	Process {
		command: ["sh", "-c", "asdbctl get"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: root.appleDisplayPresent = text.trim().length > 0
		}
	}

	Process {
		id: ddcProc

		command: ["ddcutil", "detect", "--brief"]

		stdout: StdioCollector {
			onStreamFinished: root.ddcMonitors = text.trim().split("\n\n").filter(d => d.startsWith("Display ")).map(d => ({
						busNum: d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/)[1],
						connector: d.match(/DRM connector:\s+(.*)/)[1].replace(/^card\d+-/, "") // strip "card1-"
					}))
		}
	}

	Process {
		id: ddcServiceProc

		command: ["ddcutil-client", "detect"]

		// running: true

		stdout: StdioCollector {
			onStreamFinished: {
				const t = text.replace(/\r\n/g, "\n").trim();

				const output = ("\n" + t).split(/\n(?=display:\s*\d+\s*\n)/).filter(b => b.startsWith("display:")).map(b => ({
							display: Number(b.match(/^display:\s*(\d+)/m)?.[1] ?? -1),
							name: (b.match(/^\s*product_name:\s*(.*)$/m)?.[1] ?? "").trim()
						})).filter(d => d.display > 0);
				root.ddcServiceMon = output;
			}
		}
	}

	CustomShortcut {
		description: "Increase brightness"
		name: "brightnessUp"

		onPressed: root.increaseBrightness()
	}

	CustomShortcut {
		description: "Decrease brightness"
		name: "brightnessDown"

		onPressed: root.decreaseBrightness()
	}

	IpcHandler {
		function get(): real {
			return getFor("active");
		}

		// Allows searching by active/model/serial/id/name
		function getFor(query: string): real {
			return root.getMonitor(query)?.brightness ?? -1;
		}

		function set(value: string): string {
			return setFor("active", value);
		}

		// Handles brightness value like brightnessctl: 0.1, +0.1, 0.1-, 10%, +10%, 10%-
		function setFor(query: string, value: string): string {
			const monitor = root.getMonitor(query);
			if (!monitor)
				return "Invalid monitor: " + query;

			let targetBrightness;
			if (value.endsWith("%-")) {
				const percent = parseFloat(value.slice(0, -2));
				targetBrightness = monitor.brightness - (percent / 100);
			} else if (value.startsWith("+") && value.endsWith("%")) {
				const percent = parseFloat(value.slice(1, -1));
				targetBrightness = monitor.brightness + (percent / 100);
			} else if (value.endsWith("%")) {
				const percent = parseFloat(value.slice(0, -1));
				targetBrightness = percent / 100;
			} else if (value.startsWith("+")) {
				const increment = parseFloat(value.slice(1));
				targetBrightness = monitor.brightness + increment;
			} else if (value.endsWith("-")) {
				const decrement = parseFloat(value.slice(0, -1));
				targetBrightness = monitor.brightness - decrement;
			} else if (value.includes("%") || value.includes("-") || value.includes("+")) {
				return `Invalid brightness format: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;
			} else {
				targetBrightness = parseFloat(value);
			}

			if (isNaN(targetBrightness))
				return `Failed to parse value: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;

			monitor.setBrightness(targetBrightness);

			return `Set monitor ${monitor.modelData.name} brightness to ${+monitor.brightness.toFixed(2)}`;
		}

		target: "brightness"
	}

	component Monitor: QtObject {
		id: monitor

		property real brightness
		readonly property string busNum: root.ddcMonitors.find(m => m.connector === modelData.name)?.busNum ?? ""
		readonly property string displayNum: root.ddcServiceMon.find(m => m.name === modelData.model)?.display ?? ""
		readonly property Process initProc: Process {
			stdout: StdioCollector {
				onStreamFinished: {
					if (monitor.isDdcService) {
						const output = text.split("\n").filter(o => o.startsWith("vcp_current_value:"))[0].split(":")[1];
						const val = parseInt(output.trim());
						monitor.brightness = val / 100;
					} else if (monitor.isAppleDisplay) {
						const val = parseInt(text.trim());
						monitor.brightness = val / 101;
					} else {
						const [, , , cur, max] = text.split(" ");
						monitor.brightness = parseInt(cur) / parseInt(max);
					}
				}
			}
		}
		readonly property bool isAppleDisplay: root.appleDisplayPresent && modelData.model.startsWith("StudioDisplay")
		readonly property bool isDdc: root.ddcMonitors.some(m => m.connector === modelData.name)
		readonly property bool isDdcService: Config.services.ddcutilService
		required property ShellScreen modelData
		property real queuedBrightness: NaN
		readonly property Timer timer: Timer {
			interval: 500

			onTriggered: {
				if (!isNaN(monitor.queuedBrightness)) {
					monitor.setBrightness(monitor.queuedBrightness);
					monitor.queuedBrightness = NaN;
				}
			}
		}

		function initBrightness(): void {
			if (isDdcService)
				initProc.command = ["ddcutil-client", "-d", displayNum, "getvcp", "10"];
			else if (isAppleDisplay)
				initProc.command = ["asdbctl", "get"];
			else if (isDdc)
				initProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"];
			else
				initProc.command = ["sh", "-c", "echo a b c $(brightnessctl g) $(brightnessctl m)"];

			initProc.running = true;
		}

		function setBrightness(value: real): void {
			value = Math.max(0, Math.min(1, value));
			const rounded = Math.round(value * 100);
			if (Math.round(brightness * 100) === rounded)
				return;

			if ((isDdc || isDdcService) && timer.running) {
				queuedBrightness = value;
				return;
			}

			brightness = value;

			if (isDdcService)
				Quickshell.execDetached(["ddcutil-client", "-d", displayNum, "setvcp", "10", rounded]);
			else if (isAppleDisplay)
				Quickshell.execDetached(["asdbctl", "set", rounded]);
			else if (isDdc)
				Quickshell.execDetached(["ddcutil", "--disable-dynamic-sleep", "--sleep-multiplier", ".1", "--skip-ddc-checks", "-b", busNum, "setvcp", "10", rounded]);
			else
				Quickshell.execDetached(["brightnessctl", "s", `${rounded}%`]);

			if (isDdc || isDdcService)
				timer.restart();
		}

		Component.onCompleted: initBrightness()
		onBusNumChanged: initBrightness()
		onDisplayNumChanged: initBrightness()
	}
}
