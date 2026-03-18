import QtQuick
import qs.Config

BaseStyledSlider {
	id: root

	trackContent: Component {
		Item {
			property var groove
			readonly property real handleHeight: handleItem ? handleItem.height : 0
			property var handleItem
			readonly property real handleWidth: handleItem ? handleItem.width : 0

			// Set by BaseStyledSlider's Loader
			property var rootSlider

			anchors.fill: parent

			CustomRect {
				color: rootSlider?.color
				height: rootSlider?.isVertical ? handleHeight + (1 - rootSlider?.visualPosition) * (groove?.height - handleHeight) : groove?.height
				radius: groove?.radius
				width: rootSlider?.isHorizontal ? handleWidth + rootSlider?.visualPosition * (groove?.width - handleWidth) : groove?.width
				x: rootSlider?.isHorizontal ? (rootSlider?.mirrored ? groove?.width - width : 0) : 0
				y: rootSlider?.isVertical ? groove?.height - height : 0
			}
		}
	}
}
