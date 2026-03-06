pragma ComponentBehavior: Bound

import ZShell
import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property bool flag
	readonly property int spacing: Appearance.spacing.small

	implicitHeight: {
		let h = -spacing;
		for (let i = 0; i < repeater.count; i++) {
			const item = repeater.itemAt(i) as ToastWrapper;
			if (!item.modelData.closed && !item.previewHidden)
				h += item.implicitHeight + spacing;
		}
		return h;
	}
	implicitWidth: Config.utilities.sizes.toastWidth - Appearance.padding.normal * 2

	Repeater {
		id: repeater

		model: ScriptModel {
			values: {
				const toasts = [];
				let count = 0;
				for (const toast of Toaster.toasts) {
					toasts.push(toast);
					if (!toast.closed) {
						count++;
						if (count > Config.utilities.maxToasts)
							break;
					}
				}
				return toasts;
			}

			onValuesChanged: root.flagChanged()
		}

		ToastWrapper {
		}
	}

	component ToastWrapper: MouseArea {
		id: toast

		required property int index
		required property Toast modelData
		readonly property bool previewHidden: {
			let extraHidden = 0;
			for (let i = 0; i < index; i++)
				if (Toaster.toasts[i].closed)
					extraHidden++;
			return index >= Config.utilities.maxToasts + extraHidden;
		}

		acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
		anchors.bottom: parent.bottom
		anchors.bottomMargin: {
			root.flag; // Force update
			let y = 0;
			for (let i = 0; i < index; i++) {
				const item = repeater.itemAt(i) as ToastWrapper;
				if (item && !item.modelData.closed && !item.previewHidden)
					y += item.implicitHeight + root.spacing;
			}
			return y;
		}
		anchors.left: parent.left
		anchors.right: parent.right
		implicitHeight: toastInner.implicitHeight
		opacity: modelData.closed || previewHidden ? 0 : 1
		scale: modelData.closed || previewHidden ? 0.7 : 1

		Behavior on anchors.bottomMargin {
			Anim {
				duration: Appearance.anim.durations.expressiveDefaultSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
			}
		}
		Behavior on opacity {
			Anim {
			}
		}
		Behavior on scale {
			Anim {
			}
		}

		Component.onCompleted: modelData.lock(this)
		onClicked: modelData.close()
		onPreviewHiddenChanged: {
			if (initAnim.running && previewHidden)
				initAnim.stop();
		}

		Anim {
			id: initAnim

			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
			from: 0
			properties: "opacity,scale"
			target: toast
			to: 1

			Component.onCompleted: running = !toast.previewHidden
		}

		ParallelAnimation {
			running: toast.modelData.closed

			onFinished: toast.modelData.unlock(toast)
			onStarted: toast.anchors.bottomMargin = toast.anchors.bottomMargin

			Anim {
				property: "opacity"
				target: toast
				to: 0
			}

			Anim {
				property: "scale"
				target: toast
				to: 0.7
			}
		}

		ToastItem {
			id: toastInner

			modelData: toast.modelData
		}
	}
}
