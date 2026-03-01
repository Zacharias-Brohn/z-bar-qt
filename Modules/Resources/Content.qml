import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	readonly property int minWidth: 400 + 400 + Appearance.spacing.normal + 120 + Appearance.padding.large * 2
	readonly property real nonAnimHeight: (placeholder.visible ? placeholder.height : content.implicitHeight) + Appearance.padding.normal * 2
	readonly property real nonAnimWidth: Math.max(minWidth, content.implicitWidth) + Appearance.padding.normal * 2
	required property real padding
	required property PersistentProperties visibilities

	function displayTemp(temp: real): string {
		return `${Math.ceil(temp)}°C`;
	}

	implicitHeight: nonAnimHeight
	implicitWidth: nonAnimWidth

	CustomRect {
		id: placeholder

		anchors.centerIn: parent
		color: DynamicColors.tPalette.m3surfaceContainer
		height: 350
		radius: Appearance.rounding.large - 10
		visible: false
		width: 400

		ColumnLayout {
			anchors.centerIn: parent
			spacing: Appearance.spacing.normal

			MaterialIcon {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.extraLarge * 2
				text: "tune"
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurface
				font.pointSize: Appearance.font.size.large
				text: qsTr("No widgets enabled")
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.small
				text: qsTr("Enable widgets in dashboard settings")
			}
		}
	}

	RowLayout {
		id: content

		anchors.left: parent.left
		anchors.leftMargin: root.padding
		anchors.right: parent.right
		anchors.rightMargin: root.padding
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.normal
		visible: !placeholder.visible

		Ref {
			service: SystemUsage
		}

		ColumnLayout {
			id: mainColumn

			Layout.fillWidth: true
			spacing: Appearance.spacing.normal

			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal
				visible: true

				HeroCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 400
					Layout.preferredHeight: 150
					accentColor: DynamicColors.palette.m3primary
					icon: "memory"
					mainLabel: qsTr("Usage")
					mainValue: `${Math.round(SystemUsage.cpuPerc * 100)}%`
					secondaryLabel: qsTr("Temp")
					secondaryValue: root.displayTemp(SystemUsage.cpuTemp)
					temperature: SystemUsage.cpuTemp
					title: SystemUsage.cpuName ? `CPU - ${SystemUsage.cpuName}` : qsTr("CPU")
					usage: SystemUsage.cpuPerc
					visible: Config.dashboard.performance.showCpu
				}

				HeroCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 400
					Layout.preferredHeight: 150
					accentColor: DynamicColors.palette.m3secondary
					icon: "desktop_windows"
					mainLabel: qsTr("Usage")
					mainValue: `${Math.round(SystemUsage.gpuPerc * 100)}%`
					secondaryLabel: qsTr("Temp")
					secondaryValue: root.displayTemp(SystemUsage.gpuTemp)
					temperature: SystemUsage.gpuTemp
					title: SystemUsage.gpuName ? `GPU - ${SystemUsage.gpuName}` : qsTr("GPU")
					usage: SystemUsage.gpuPerc
					visible: Config.dashboard.performance.showGpu && SystemUsage.gpuType !== "NONE"
				}
			}

			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal
				visible: Config.dashboard.performance.showMemory || Config.dashboard.performance.showStorage || Config.dashboard.performance.showNetwork

				GaugeCard {
					Layout.fillWidth: !Config.dashboard.performance.showStorage && !Config.dashboard.performance.showNetwork
					Layout.minimumWidth: 250
					Layout.preferredHeight: 220
					accentColor: DynamicColors.palette.m3tertiary
					icon: "memory_alt"
					percentage: SystemUsage.memPerc
					subtitle: {
						const usedFmt = SystemUsage.formatKib(SystemUsage.memUsed);
						const totalFmt = SystemUsage.formatKib(SystemUsage.memTotal);
						return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
					}
					title: qsTr("Memory")
					visible: Config.dashboard.performance.showMemory
				}

				StorageGaugeCard {
					Layout.fillWidth: !Config.dashboard.performance.showNetwork
					Layout.minimumWidth: 250
					Layout.preferredHeight: 220
					visible: Config.dashboard.performance.showStorage
				}

				NetworkCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 200
					Layout.preferredHeight: 220
					visible: Config.dashboard.performance.showNetwork
				}
			}
		}

		BatteryTank {
			Layout.preferredHeight: mainColumn.implicitHeight
			Layout.preferredWidth: 120
			visible: UPower.displayDevice.isLaptopBattery && Config.dashboard.performance.showBattery
		}
	}

	component BatteryTank: CustomClippingRect {
		id: batteryTank

		property color accentColor: DynamicColors.palette.m3primary
		property real animatedPercentage: 0
		property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
		property real percentage: UPower.displayDevice.percentage

		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large - 10

		Behavior on animatedPercentage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: animatedPercentage = percentage
		onPercentageChanged: animatedPercentage = percentage

		// Background Fill
		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			color: Qt.alpha(batteryTank.accentColor, 0.15)
			height: parent.height * batteryTank.animatedPercentage
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.small

			// Header Section
			ColumnLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.small

				MaterialIcon {
					color: batteryTank.accentColor
					font.pointSize: Appearance.font.size.large
					text: {
						if (!UPower.displayDevice.isLaptopBattery) {
							if (PowerProfiles.profile === PowerProfile.PowerSaver)
								return "energy_savings_leaf";

							if (PowerProfiles.profile === PowerProfile.Performance)
								return "rocket_launch";

							return "balance";
						}
						if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
							return "battery_full";

						const perc = UPower.displayDevice.percentage;
						const charging = [UPowerDeviceState.Charging, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state);
						if (perc >= 0.99)
							return "battery_full";

						let level = Math.floor(perc * 7);
						if (charging && (level === 4 || level === 1))
							level--;

						return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
					}
				}

				CustomText {
					Layout.fillWidth: true
					color: DynamicColors.palette.m3onSurface
					font.pointSize: Appearance.font.size.normal
					text: qsTr("Battery")
				}
			}

			Item {
				Layout.fillHeight: true
			}

			// Bottom Info Section
			ColumnLayout {
				Layout.fillWidth: true
				spacing: -4

				CustomText {
					Layout.alignment: Qt.AlignRight
					color: batteryTank.accentColor
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: Font.Medium
					text: `${Math.round(batteryTank.percentage * 100)}%`
				}

				CustomText {
					Layout.alignment: Qt.AlignRight
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.smaller
					text: {
						if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
							return qsTr("Full");

						if (batteryTank.isCharging)
							return qsTr("Charging");

						const s = UPower.displayDevice.timeToEmpty;
						if (s === 0)
							return qsTr("...");

						const hr = Math.floor(s / 3600);
						const min = Math.floor((s % 3600) / 60);
						if (hr > 0)
							return `${hr}h ${min}m`;

						return `${min}m`;
					}
				}
			}
		}
	}
	component CardHeader: RowLayout {
		property color accentColor: DynamicColors.palette.m3primary
		property string icon
		property string title

		Layout.fillWidth: true
		spacing: Appearance.spacing.small

		MaterialIcon {
			color: parent.accentColor
			fill: 1
			font.pointSize: Appearance.spacing.large
			text: parent.icon
		}

		CustomText {
			Layout.fillWidth: true
			elide: Text.ElideRight
			font.pointSize: Appearance.font.size.normal
			text: parent.title
		}
	}
	component GaugeCard: CustomRect {
		id: gaugeCard

		property color accentColor: DynamicColors.palette.m3primary
		property real animatedPercentage: 0
		readonly property real arcStartAngle: 0.75 * Math.PI
		readonly property real arcSweep: 1.5 * Math.PI
		property string icon
		property real percentage: 0
		property string subtitle
		property string title

		clip: true
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large - 10

		Behavior on animatedPercentage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: animatedPercentage = percentage
		onPercentageChanged: animatedPercentage = percentage

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.smaller

			CardHeader {
				accentColor: gaugeCard.accentColor
				icon: gaugeCard.icon
				title: gaugeCard.title
			}

			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true

				Canvas {
					id: gaugeCanvas

					anchors.centerIn: parent
					height: width
					width: Math.min(parent.width, parent.height)

					Component.onCompleted: requestPaint()
					onPaint: {
						const ctx = getContext("2d");
						ctx.reset();
						const cx = width / 2;
						const cy = height / 2;
						const radius = (Math.min(width, height) - 12) / 2;
						const lineWidth = 10;
						ctx.beginPath();
						ctx.arc(cx, cy, radius, gaugeCard.arcStartAngle, gaugeCard.arcStartAngle + gaugeCard.arcSweep);
						ctx.lineWidth = lineWidth;
						ctx.lineCap = "round";
						ctx.strokeStyle = DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2);
						ctx.stroke();
						if (gaugeCard.animatedPercentage > 0) {
							ctx.beginPath();
							ctx.arc(cx, cy, radius, gaugeCard.arcStartAngle, gaugeCard.arcStartAngle + gaugeCard.arcSweep * gaugeCard.animatedPercentage);
							ctx.lineWidth = lineWidth;
							ctx.lineCap = "round";
							ctx.strokeStyle = gaugeCard.accentColor;
							ctx.stroke();
						}
					}

					Connections {
						function onAnimatedPercentageChanged() {
							gaugeCanvas.requestPaint();
						}

						target: gaugeCard
					}

					Connections {
						function onPaletteChanged() {
							gaugeCanvas.requestPaint();
						}

						target: DynamicColors
					}
				}

				CustomText {
					anchors.centerIn: parent
					color: gaugeCard.accentColor
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: Font.Medium
					text: `${Math.round(gaugeCard.percentage * 100)}%`
				}
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.smaller
				text: gaugeCard.subtitle
			}
		}
	}
	component HeroCard: CustomClippingRect {
		id: heroCard

		property color accentColor: DynamicColors.palette.m3primary
		property real animatedTemp: 0
		property real animatedUsage: 0
		property string icon
		property string mainLabel
		property string mainValue
		readonly property real maxTemp: 100
		property string secondaryLabel
		property string secondaryValue
		readonly property real tempProgress: Math.min(1, Math.max(0, temperature / maxTemp))
		property real temperature: 0
		property string title
		property real usage: 0

		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large - 10

		Behavior on animatedTemp {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}
		Behavior on animatedUsage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: {
			animatedUsage = usage;
			animatedTemp = tempProgress;
		}
		onTempProgressChanged: animatedTemp = tempProgress
		onUsageChanged: animatedUsage = usage

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: parent.top
			color: Qt.alpha(heroCard.accentColor, 0.15)
			width: parent.width * heroCard.animatedUsage
		}

		ColumnLayout {
			anchors.bottomMargin: Appearance.padding.normal
			anchors.fill: parent
			anchors.leftMargin: Appearance.padding.large
			anchors.rightMargin: Appearance.padding.large
			anchors.topMargin: Appearance.padding.normal
			spacing: Appearance.spacing.small

			CardHeader {
				accentColor: heroCard.accentColor
				icon: heroCard.icon
				title: heroCard.title
			}

			RowLayout {
				Layout.fillHeight: true
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				Column {
					Layout.alignment: Qt.AlignBottom
					Layout.fillWidth: true
					spacing: Appearance.spacing.small

					Row {
						spacing: Appearance.spacing.small

						CustomText {
							font.pointSize: Appearance.font.size.normal
							font.weight: Font.Medium
							text: heroCard.secondaryValue
						}

						CustomText {
							anchors.baseline: parent.children[0].baseline
							color: DynamicColors.palette.m3onSurfaceVariant
							font.pointSize: Appearance.font.size.small
							text: heroCard.secondaryLabel
						}
					}

					ProgressBar {
						bgColor: Qt.alpha(heroCard.accentColor, 0.2)
						fgColor: heroCard.accentColor
						height: 6
						value: heroCard.tempProgress
						width: parent.width * 0.5
					}
				}

				Item {
					Layout.fillWidth: true
				}
			}
		}

		Column {
			anchors.margins: Appearance.padding.large
			anchors.right: parent.right
			anchors.rightMargin: 32
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0

			CustomText {
				anchors.right: parent.right
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.normal
				text: heroCard.mainLabel
			}

			CustomText {
				anchors.right: parent.right
				color: heroCard.accentColor
				font.pointSize: Appearance.font.size.extraLarge
				font.weight: Font.Medium
				text: heroCard.mainValue
			}
		}
	}
	component NetworkCard: CustomRect {
		id: networkCard

		property color accentColor: DynamicColors.palette.m3primary

		clip: true
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large - 10

		Ref {
			service: NetworkUsage
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.small

			CardHeader {
				accentColor: networkCard.accentColor
				icon: "swap_vert"
				title: qsTr("Network")
			}

			// Sparkline graph
			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true

				Canvas {
					id: sparklineCanvas

					property int _lastTickCount: -1
					property int _tickCount: 0
					property var downHistory: NetworkUsage.downloadHistory
					property real slideProgress: 0
					property real smoothMax: targetMax
					property real targetMax: 1024
					property var upHistory: NetworkUsage.uploadHistory

					function checkAndAnimate(): void {
						const currentLength = (downHistory || []).length;
						if (currentLength > 0 && _tickCount !== _lastTickCount) {
							_lastTickCount = _tickCount;
							updateMax();
						}
					}

					function updateMax(): void {
						const downHist = downHistory || [];
						const upHist = upHistory || [];
						const allValues = downHist.concat(upHist);
						targetMax = Math.max(...allValues, 1024);
						requestPaint();
					}

					anchors.fill: parent

					NumberAnimation on slideProgress {
						duration: Config.dashboard.resourceUpdateInterval
						from: 0
						loops: Animation.Infinite
						running: true
						to: 1
					}
					Behavior on smoothMax {
						Anim {
							duration: Appearance.anim.durations.large
						}
					}

					Component.onCompleted: updateMax()
					onDownHistoryChanged: checkAndAnimate()
					onPaint: {
						const ctx = getContext("2d");
						ctx.reset();
						const w = width;
						const h = height;
						const downHist = downHistory || [];
						const upHist = upHistory || [];
						if (downHist.length < 2 && upHist.length < 2)
							return;

						const maxVal = smoothMax;

						const drawLine = (history, color, fillAlpha) => {
							if (history.length < 2)
								return;

							const len = history.length;
							const stepX = w / (NetworkUsage.historyLength - 1);
							const startX = w - (len - 1) * stepX - stepX * slideProgress + stepX;
							ctx.beginPath();
							ctx.moveTo(startX, h - (history[0] / maxVal) * h);
							for (let i = 1; i < len; i++) {
								const x = startX + i * stepX;
								const y = h - (history[i] / maxVal) * h;
								ctx.lineTo(x, y);
							}
							ctx.strokeStyle = color;
							ctx.lineWidth = 2;
							ctx.lineCap = "round";
							ctx.lineJoin = "round";
							ctx.stroke();
							ctx.lineTo(startX + (len - 1) * stepX, h);
							ctx.lineTo(startX, h);
							ctx.closePath();
							ctx.fillStyle = Qt.rgba(Qt.color(color).r, Qt.color(color).g, Qt.color(color).b, fillAlpha);
							ctx.fill();
						};

						drawLine(upHist, DynamicColors.palette.m3secondary.toString(), 0.15);
						drawLine(downHist, DynamicColors.palette.m3tertiary.toString(), 0.2);
					}
					onSlideProgressChanged: requestPaint()
					onSmoothMaxChanged: requestPaint()
					onUpHistoryChanged: checkAndAnimate()

					Connections {
						function onPaletteChanged() {
							sparklineCanvas.requestPaint();
						}

						target: DynamicColors
					}

					Timer {
						interval: Config.dashboard.resourceUpdateInterval
						repeat: true
						running: true

						onTriggered: sparklineCanvas._tickCount++
					}
				}

				// "No data" placeholder
				CustomText {
					anchors.centerIn: parent
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					opacity: 0.6
					text: qsTr("Collecting data...")
					visible: NetworkUsage.downloadHistory.length < 2
				}
			}

			// Download row
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				MaterialIcon {
					color: DynamicColors.palette.m3tertiary
					font.pointSize: Appearance.font.size.normal
					text: "download"
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: qsTr("Download")
				}

				Item {
					Layout.fillWidth: true
				}

				CustomText {
					color: DynamicColors.palette.m3tertiary
					font.pointSize: Appearance.font.size.normal
					font.weight: Font.Medium
					text: {
						const fmt = NetworkUsage.formatBytes(NetworkUsage.downloadSpeed ?? 0);
						return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit}` : "0.0 B/s";
					}
				}
			}

			// Upload row
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				MaterialIcon {
					color: DynamicColors.palette.m3secondary
					font.pointSize: Appearance.font.size.normal
					text: "upload"
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: qsTr("Upload")
				}

				Item {
					Layout.fillWidth: true
				}

				CustomText {
					color: DynamicColors.palette.m3secondary
					font.pointSize: Appearance.font.size.normal
					font.weight: Font.Medium
					text: {
						const fmt = NetworkUsage.formatBytes(NetworkUsage.uploadSpeed ?? 0);
						return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit}` : "0.0 B/s";
					}
				}
			}

			// Session totals
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				MaterialIcon {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.normal
					text: "history"
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: qsTr("Total")
				}

				Item {
					Layout.fillWidth: true
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: {
						const down = NetworkUsage.formatBytesTotal(NetworkUsage.downloadTotal ?? 0);
						const up = NetworkUsage.formatBytesTotal(NetworkUsage.uploadTotal ?? 0);
						return (down && up) ? `↓${down.value.toFixed(1)}${down.unit} ↑${up.value.toFixed(1)}${up.unit}` : "↓0.0B ↑0.0B";
					}
				}
			}
		}
	}
	component ProgressBar: CustomRect {
		id: progressBar

		property real animatedValue: 0
		property color bgColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		property color fgColor: DynamicColors.palette.m3primary
		property real value: 0

		color: bgColor
		radius: Appearance.rounding.full

		Behavior on animatedValue {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: animatedValue = value
		onValueChanged: animatedValue = value

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: parent.top
			color: progressBar.fgColor
			radius: Appearance.rounding.full
			width: parent.width * progressBar.animatedValue
		}
	}
	component StorageGaugeCard: CustomRect {
		id: storageGaugeCard

		property color accentColor: DynamicColors.palette.m3secondary
		property real animatedPercentage: 0
		readonly property real arcStartAngle: 0.75 * Math.PI
		readonly property real arcSweep: 1.5 * Math.PI
		readonly property var currentDisk: SystemUsage.disks.length > 0 ? SystemUsage.disks[currentDiskIndex] : null
		property int currentDiskIndex: 0
		property int diskCount: 0

		clip: true
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large - 10

		Behavior on animatedPercentage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: {
			diskCount = SystemUsage.disks.length;
			if (currentDisk)
				animatedPercentage = currentDisk.perc;
		}
		onCurrentDiskChanged: {
			if (currentDisk)
				animatedPercentage = currentDisk.perc;
		}

		// Update diskCount and animatedPercentage when disks data changes
		Connections {
			function onDisksChanged() {
				if (SystemUsage.disks.length !== storageGaugeCard.diskCount)
					storageGaugeCard.diskCount = SystemUsage.disks.length;

				// Update animated percentage when disk data refreshes
				if (storageGaugeCard.currentDisk)
					storageGaugeCard.animatedPercentage = storageGaugeCard.currentDisk.perc;
			}

			target: SystemUsage
		}

		MouseArea {
			anchors.fill: parent

			onWheel: wheel => {
				if (wheel.angleDelta.y > 0)
					storageGaugeCard.currentDiskIndex = (storageGaugeCard.currentDiskIndex - 1 + storageGaugeCard.diskCount) % storageGaugeCard.diskCount;
				else if (wheel.angleDelta.y < 0)
					storageGaugeCard.currentDiskIndex = (storageGaugeCard.currentDiskIndex + 1) % storageGaugeCard.diskCount;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.smaller

			CardHeader {
				accentColor: storageGaugeCard.accentColor
				icon: "hard_disk"
				title: {
					const base = qsTr("Storage");
					if (!storageGaugeCard.currentDisk)
						return base;

					return `${base} - ${storageGaugeCard.currentDisk.mount}`;
				}

				// Scroll hint icon
				MaterialIcon {
					ToolTip.delay: 500
					ToolTip.text: qsTr("Scroll to switch disks")
					ToolTip.visible: hintHover.hovered
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.normal
					opacity: 0.7
					text: "unfold_more"
					visible: storageGaugeCard.diskCount > 1

					HoverHandler {
						id: hintHover

					}
				}
			}

			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true

				Canvas {
					id: storageGaugeCanvas

					anchors.centerIn: parent
					height: width
					width: Math.min(parent.width, parent.height)

					Component.onCompleted: requestPaint()
					onPaint: {
						const ctx = getContext("2d");
						ctx.reset();
						const cx = width / 2;
						const cy = height / 2;
						const radius = (Math.min(width, height) - 12) / 2;
						const lineWidth = 10;
						ctx.beginPath();
						ctx.arc(cx, cy, radius, storageGaugeCard.arcStartAngle, storageGaugeCard.arcStartAngle + storageGaugeCard.arcSweep);
						ctx.lineWidth = lineWidth;
						ctx.lineCap = "round";
						ctx.strokeStyle = DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2);
						ctx.stroke();
						if (storageGaugeCard.animatedPercentage > 0) {
							ctx.beginPath();
							ctx.arc(cx, cy, radius, storageGaugeCard.arcStartAngle, storageGaugeCard.arcStartAngle + storageGaugeCard.arcSweep * storageGaugeCard.animatedPercentage);
							ctx.lineWidth = lineWidth;
							ctx.lineCap = "round";
							ctx.strokeStyle = storageGaugeCard.accentColor;
							ctx.stroke();
						}
					}

					Connections {
						function onAnimatedPercentageChanged() {
							storageGaugeCanvas.requestPaint();
						}

						target: storageGaugeCard
					}

					Connections {
						function onPaletteChanged() {
							storageGaugeCanvas.requestPaint();
						}

						target: DynamicColors
					}
				}

				CustomText {
					anchors.centerIn: parent
					color: storageGaugeCard.accentColor
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: Font.Medium
					text: storageGaugeCard.currentDisk ? `${Math.round(storageGaugeCard.currentDisk.perc * 100)}%` : "—"
				}
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.smaller
				text: {
					if (!storageGaugeCard.currentDisk)
						return "—";

					const usedFmt = SystemUsage.formatKib(storageGaugeCard.currentDisk.used);
					const totalFmt = SystemUsage.formatKib(storageGaugeCard.currentDisk.total);
					return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
				}
			}
		}
	}
}
