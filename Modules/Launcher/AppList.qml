pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Modules.Launcher.Services
import qs.Modules.Launcher.Items
import qs.Components
import qs.Config

CustomListView {
	id: root

	required property CustomTextField search
	required property PersistentProperties visibilities

	highlightFollowsCurrentItem: false
	highlightRangeMode: ListView.ApplyRange
	implicitHeight: (Config.launcher.sizes.itemHeight + spacing) * Math.min(Config.launcher.maxAppsShown, count) - spacing
	orientation: Qt.Vertical
	preferredHighlightBegin: 0
	preferredHighlightEnd: height
	spacing: Appearance.spacing.small
	state: {
		const text = search.text;
		const prefix = Config.launcher.actionPrefix;
		if (text.startsWith(prefix)) {
			for (const action of ["calc", "scheme", "variant"])
				if (text.startsWith(`${prefix}${action} `))
					return action;

			return "actions";
		}

		return "apps";
	}
	verticalLayoutDirection: ListView.BottomToTop

	CustomScrollBar.vertical: CustomScrollBar {
		flickable: root
	}
	add: Transition {
		enabled: !root.state

		Anim {
			from: 0
			properties: "opacity,scale"
			to: 1
		}
	}
	addDisplaced: Transition {
		Anim {
			duration: Appearance.anim.durations.small
			property: "y"
		}

		Anim {
			properties: "opacity,scale"
			to: 1
		}
	}
	displaced: Transition {
		Anim {
			property: "y"
		}

		Anim {
			properties: "opacity,scale"
			to: 1
		}
	}
	highlight: CustomRect {
		color: DynamicColors.palette.m3onSurface
		implicitHeight: root.currentItem?.implicitHeight ?? 0
		implicitWidth: root.width
		opacity: 0.08
		radius: 8
		y: root.currentItem?.y ?? 0

		Behavior on y {
			Anim {
				duration: Appearance.anim.durations.small
				easing.bezierCurve: Appearance.anim.curves.expressiveEffects
			}
		}
	}
	model: ScriptModel {
		id: model

		onValuesChanged: root.currentIndex = 0
	}
	move: Transition {
		Anim {
			property: "y"
		}

		Anim {
			properties: "opacity,scale"
			to: 1
		}
	}
	remove: Transition {
		enabled: !root.state

		Anim {
			from: 1
			properties: "opacity,scale"
			to: 0
		}
	}
	states: [
		State {
			name: "apps"

			PropertyChanges {
				model.values: Apps.search(search.text)
				root.delegate: appItem
			}
		},
		State {
			name: "actions"

			PropertyChanges {
				model.values: Actions.query(search.text)
				root.delegate: actionItem
			}
		},
		State {
			name: "calc"

			PropertyChanges {
				model.values: [0]
				root.delegate: calcItem
			}
		}
	]
	transitions: Transition {
		SequentialAnimation {
			ParallelAnimation {
				Anim {
					duration: Appearance.anim.durations.small
					easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					from: 1
					property: "opacity"
					target: root
					to: 0
				}

				Anim {
					duration: Appearance.anim.durations.small
					easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					from: 1
					property: "scale"
					target: root
					to: 0.9
				}
			}

			PropertyAction {
				properties: "values,delegate"
				targets: [model, root]
			}

			ParallelAnimation {
				Anim {
					duration: Appearance.anim.durations.small
					easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					from: 0
					property: "opacity"
					target: root
					to: 1
				}

				Anim {
					duration: Appearance.anim.durations.small
					easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					from: 0.9
					property: "scale"
					target: root
					to: 1
				}
			}

			PropertyAction {
				property: "enabled"
				targets: [root.add, root.remove]
				value: true
			}
		}
	}

	Component {
		id: appItem

		AppItem {
			visibilities: root.visibilities
		}
	}

	Component {
		id: actionItem

		ActionItem {
			list: root
		}
	}

	Component {
		id: calcItem

		CalcItem {
			list: root
		}
	}
}
