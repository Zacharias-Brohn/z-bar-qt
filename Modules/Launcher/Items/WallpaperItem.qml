import ZShell.Models
import Quickshell
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules

Item {
	id: root

	required property FileSystemEntry modelData
	required property PersistentProperties visibilities

	implicitHeight: image.height + label.height + Appearance.spacing.small / 2 + Appearance.padding.large + Appearance.padding.normal
	implicitWidth: image.width + Appearance.padding.larger * 2
	opacity: 0
	scale: 0.5
	z: PathView.z ?? 0

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}

	Component.onCompleted: {
		scale = Qt.binding(() => PathView.isCurrentItem ? 1 : PathView.onPath ? 0.8 : 0);
		opacity = Qt.binding(() => PathView.onPath ? 1 : 0);
	}

	StateLayer {
		function onClicked(): void {
			console.log(root.modelData.path);
			Wallpapers.setWallpaper(root.modelData.path);
			root.visibilities.launcher = false;
		}

		radius: Appearance.rounding.normal
	}

	Elevation {
		anchors.fill: image
		level: 4
		opacity: root.PathView.isCurrentItem ? 1 : 0
		radius: image.radius

		Behavior on opacity {
			Anim {
			}
		}
	}

	CustomClippingRect {
		id: image

		anchors.horizontalCenter: parent.horizontalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: implicitWidth / 16 * 9
		implicitWidth: Config.launcher.sizes.wallpaperWidth
		radius: Appearance.rounding.normal
		y: Appearance.padding.large

		MaterialIcon {
			anchors.centerIn: parent
			color: DynamicColors.tPalette.m3outline
			font.pointSize: Appearance.font.size.extraLarge * 2
			font.weight: 600
			text: "image"
		}

		CachingImage {
			anchors.fill: parent
			cache: true
			path: root.modelData.path
			smooth: !root.PathView.view.moving
		}
	}

	CustomText {
		id: label

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: image.bottom
		anchors.topMargin: Appearance.spacing.small / 2
		elide: Text.ElideRight
		font.pointSize: Appearance.font.size.normal
		horizontalAlignment: Text.AlignHCenter
		renderType: Text.QtRendering
		text: root.modelData.relativePath
		width: image.width - Appearance.padding.normal * 2
	}
}
