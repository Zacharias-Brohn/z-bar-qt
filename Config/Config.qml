pragma Singleton

import Quickshell
import Quickshell.Io
import ZShell
import QtQuick
import qs.Helpers
import qs.Paths

Singleton {
	id: root

	property alias appearance: adapter.appearance
	property alias background: adapter.background
	property alias barConfig: adapter.barConfig
	property alias colors: adapter.colors
	property alias dashboard: adapter.dashboard
	property alias general: adapter.general
	property alias launcher: adapter.launcher
	property alias lock: adapter.lock
	property alias notifs: adapter.notifs
	property alias osd: adapter.osd
	property alias overview: adapter.overview
	property bool recentlySaved: false
	property alias services: adapter.services
	property alias sidebar: adapter.sidebar
	property alias utilities: adapter.utilities

	function save(): void {
		saveTimer.restart();
		recentlySaved = true;
		recentSaveCooldown.restart();
	}

	function serializeAppearance(): var {
		return {
			rounding: {
				scale: appearance.rounding.scale
			},
			spacing: {
				scale: appearance.spacing.scale
			},
			padding: {
				scale: appearance.padding.scale
			},
			font: {
				family: {
					sans: appearance.font.family.sans,
					mono: appearance.font.family.mono,
					material: appearance.font.family.material,
					clock: appearance.font.family.clock
				},
				size: {
					scale: appearance.font.size.scale
				}
			},
			anim: {
				mediaGifSpeedAdjustment: 300,
				sessionGifSpeed: 0.7,
				durations: {
					scale: appearance.anim.durations.scale
				}
			},
			transparency: {
				enabled: appearance.transparency.enabled,
				base: appearance.transparency.base,
				layers: appearance.transparency.layers
			}
		};
	}

	function serializeBackground(): var {
		return {
			wallFadeDuration: background.wallFadeDuration,
			enabled: background.enabled
		};
	}

	function serializeBar(): var {
		return {
			autoHide: barConfig.autoHide,
			rounding: barConfig.rounding,
			popouts: {
				tray: barConfig.popouts.tray,
				audio: barConfig.popouts.audio,
				activeWindow: barConfig.popouts.activeWindow,
				resources: barConfig.popouts.resources,
				clock: barConfig.popouts.clock,
				network: barConfig.popouts.network,
				upower: barConfig.popouts.upower
			},
			entries: barConfig.entries
		};
	}

	function serializeColors(): var {
		return {
			schemeType: colors.schemeType
		};
	}

	function serializeConfig(): var {
		return {
			barConfig: serializeBar(),
			lock: serializeLock(),
			general: serializeGeneral(),
			services: serializeServices(),
			notifs: serializeNotifs(),
			sidebar: serializeSidebar(),
			utilities: serializeUtilities(),
			dashboard: serializeDashboard(),
			appearance: serializeAppearance(),
			osd: serializeOsd(),
			background: serializeBackground(),
			launcher: serializeLauncher(),
			colors: serializeColors()
		};
	}

	function serializeDashboard(): var {
		return {
			enabled: dashboard.enabled,
			mediaUpdateInterval: dashboard.mediaUpdateInterval,
			dragThreshold: dashboard.dragThreshold,
			sizes: {
				tabIndicatorHeight: dashboard.sizes.tabIndicatorHeight,
				tabIndicatorSpacing: dashboard.sizes.tabIndicatorSpacing,
				infoWidth: dashboard.sizes.infoWidth,
				infoIconSize: dashboard.sizes.infoIconSize,
				dateTimeWidth: dashboard.sizes.dateTimeWidth,
				mediaWidth: dashboard.sizes.mediaWidth,
				mediaProgressSweep: dashboard.sizes.mediaProgressSweep,
				mediaProgressThickness: dashboard.sizes.mediaProgressThickness,
				resourceProgessThickness: dashboard.sizes.resourceProgessThickness,
				weatherWidth: dashboard.sizes.weatherWidth,
				mediaCoverArtSize: dashboard.sizes.mediaCoverArtSize,
				mediaVisualiserSize: dashboard.sizes.mediaVisualiserSize,
				resourceSize: dashboard.sizes.resourceSize
			}
		};
	}

	function serializeGeneral(): var {
		return {
			logo: general.logo,
			wallpaperPath: general.wallpaperPath,
			color: {
				wallust: general.color.wallust,
				mode: general.color.mode,
				schemeGeneration: general.color.schemeGeneration,
				scheduleDarkStart: general.color.scheduleDarkStart,
				scheduleDarkEnd: general.color.scheduleDarkEnd,
				neovimColors: general.color.neovimColors
			},
			apps: {
				terminal: general.apps.terminal,
				audio: general.apps.audio,
				playback: general.apps.playback,
				explorer: general.apps.explorer
			},
			idle: {
				timouts: general.idle.timeouts
			}
		};
	}

	function serializeLauncher(): var {
		return {
			maxAppsShown: launcher.maxAppsShown,
			maxWallpapers: launcher.maxWallpapers,
			actionPrefix: launcher.actionPrefix,
			specialPrefix: launcher.specialPrefix,
			useFuzzy: {
				apps: launcher.useFuzzy.apps,
				actions: launcher.useFuzzy.actions,
				schemes: launcher.useFuzzy.schemes,
				variants: launcher.useFuzzy.variants,
				wallpapers: launcher.useFuzzy.wallpapers
			},
			sizes: {
				itemWidth: launcher.sizes.itemWidth,
				itemHeight: launcher.sizes.itemHeight,
				wallpaperWidth: launcher.sizes.wallpaperWidth,
				wallpaperHeight: launcher.sizes.wallpaperHeight
			},
			actions: launcher.actions
		};
	}

	function serializeLock(): var {
		return {
			recolorLogo: lock.recolorLogo,
			enableFprint: lock.enableFprint,
			maxFprintTries: lock.maxFprintTries,
			blurAmount: lock.blurAmount,
			sizes: {
				heightMult: lock.sizes.heightMult,
				ratio: lock.sizes.ratio,
				centerWidth: lock.sizes.centerWidth
			}
		};
	}

	function serializeNotifs(): var {
		return {
			expire: notifs.expire,
			defaultExpireTimeout: notifs.defaultExpireTimeout,
			appNotifCooldown: notifs.appNotifCooldown,
			clearThreshold: notifs.clearThreshold,
			expandThreshold: notifs.expandThreshold,
			actionOnClick: notifs.actionOnClick,
			groupPreviewNum: notifs.groupPreviewNum,
			sizes: {
				width: notifs.sizes.width,
				image: notifs.sizes.image,
				badge: notifs.sizes.badge
			}
		};
	}

	function serializeOsd(): var {
		return {
			enabled: osd.enabled,
			hideDelay: osd.hideDelay,
			enableBrightness: osd.enableBrightness,
			enableMicrophone: osd.enableMicrophone,
			allMonBrightness: osd.allMonBrightness,
			sizes: {
				sliderWidth: osd.sizes.sliderWidth,
				sliderHeight: osd.sizes.sliderHeight
			}
		};
	}

	function serializeServices(): var {
		return {
			weatherLocation: services.weatherLocation,
			useFahrenheit: services.useFahrenheit,
			ddcutilService: services.ddcutilService,
			useTwelveHourClock: services.useTwelveHourClock,
			gpuType: services.gpuType,
			audioIncrement: services.audioIncrement,
			brightnessIncrement: services.brightnessIncrement,
			maxVolume: services.maxVolume,
			defaultPlayer: services.defaultPlayer,
			playerAliases: services.playerAliases,
			visualizerBars: services.visualizerBars
		};
	}

	function serializeSidebar(): var {
		return {
			enabled: sidebar.enabled,
			sizes: {
				width: sidebar.sizes.width
			}
		};
	}

	function serializeUtilities(): var {
		return {
			enabled: utilities.enabled,
			maxToasts: utilities.maxToasts,
			sizes: {
				width: utilities.sizes.width,
				toastWidth: utilities.sizes.toastWidth
			},
			toasts: {
				configLoaded: utilities.toasts.configLoaded,
				chargingChanged: utilities.toasts.chargingChanged,
				gameModeChanged: utilities.toasts.gameModeChanged,
				dndChanged: utilities.toasts.dndChanged,
				audioOutputChanged: utilities.toasts.audioOutputChanged,
				audioInputChanged: utilities.toasts.audioInputChanged,
				capsLockChanged: utilities.toasts.capsLockChanged,
				numLockChanged: utilities.toasts.numLockChanged,
				kbLayoutChanged: utilities.toasts.kbLayoutChanged,
				vpnChanged: utilities.toasts.vpnChanged,
				nowPlaying: utilities.toasts.nowPlaying
			},
			vpn: {
				enabled: utilities.vpn.enabled,
				provider: utilities.vpn.provider
			}
		};
	}

	ElapsedTimer {
		id: timer

	}

	Timer {
		id: saveTimer

		interval: 500

		onTriggered: {
			timer.restart();
			try {
				let config = {};
				try {
					config = JSON.parse(fileView.text());
				} catch (e) {
					config = {};
				}

				config = root.serializeConfig();

				fileView.setText(JSON.stringify(config, null, 4));
			} catch (e) {
				Toaster.toast(qsTr("Failed to serialize config"), e.message, "settings_alert", Toast.Error);
			}
		}
	}

	Timer {
		id: recentSaveCooldown

		interval: 2000

		onTriggered: {
			root.recentlySaved = false;
		}
	}

	FileView {
		id: fileView

		path: `${Paths.config}/config.json`
		watchChanges: true

		onFileChanged: {
			if (!root.recentlySaved) {
				timer.restart();
				reload();
			} else {
				reload();
			}
		}
		onLoadFailed: err => {
			if (err !== FileViewError.FileNotFound)
				Toaster.toast(qsTr("Failed to read config"), FileViewError.toString(err), "settings_alert", Toast.Warning);
		}
		onLoaded: {
			ModeScheduler.checkStartup();
			try {
				JSON.parse(text());
				const elapsed = timer.elapsedMs();

				if (adapter.utilities.toasts.configLoaded && !root.recentlySaved) {
					Toaster.toast(qsTr("Config loaded"), qsTr("Config loaded in %1ms").arg(elapsed), "rule_settings");
				} else if (adapter.utilities.toasts.configLoaded && root.recentlySaved) {
					Toaster.toast(qsTr("Config saved"), qsTr("Config reloaded in %1ms").arg(elapsed), "settings_alert");
				}
			} catch (e) {
				Toaster.toast(qsTr("Failed to load config"), e.message, "settings_alert", Toast.Error);
			}
		}
		onSaveFailed: err => Toaster.toast(qsTr("Failed to save config"), FileViewError.toString(err), "settings_alert", Toast.Error)

		JsonAdapter {
			id: adapter

			property AppearanceConf appearance: AppearanceConf {
			}
			property BackgroundConfig background: BackgroundConfig {
			}
			property BarConfig barConfig: BarConfig {
			}
			property Colors colors: Colors {
			}
			property DashboardConfig dashboard: DashboardConfig {
			}
			property General general: General {
			}
			property Launcher launcher: Launcher {
			}
			property LockConf lock: LockConf {
			}
			property NotifConfig notifs: NotifConfig {
			}
			property Osd osd: Osd {
			}
			property Overview overview: Overview {
			}
			property Services services: Services {
			}
			property SidebarConfig sidebar: SidebarConfig {
			}
			property UtilConfig utilities: UtilConfig {
			}
		}
	}
}
