pragma ComponentBehavior: Bound

import QtQuick
import qs.Helpers
import qs.Config

Item {
    id: root

    property string source: SearchWallpapers.current
    property Image current: one

    anchors.fill: parent

    onSourceChanged: {
        if (!source) {
            current = null;
        } else if (current === one) {
            two.update();
        } else {
            one.update();
        }
    }

    Component.onCompleted: {
        console.log(root.source)
        if (source)
            Qt.callLater(() => one.update());
    }

    Img {
        id: one
    }

    Img {
        id: two
    }

    component Img: CachingImage {
        id: img

        function update(): void {
            if (path === root.source) {
                root.current = this;
            } else {
                path = root.source;
            }
        }

        anchors.fill: parent

        opacity: 0
        scale: SearchWallpapers.showPreview ? 1 : 0.8
        asynchronous: true
        onStatusChanged: {
            if (status === Image.Ready) {
                root.current = this;
            }
        }

        states: State {
            name: "visible"
            when: root.current === img

            PropertyChanges {
                img.opacity: 1
                img.scale: 1
            }
        }

        transitions: Transition {
            Anim {
                target: img
                properties: "opacity,scale"
                duration: Config.background.wallFadeDuration
            }
        }
    }
}
