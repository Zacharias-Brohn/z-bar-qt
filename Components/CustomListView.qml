import QtQuick
import qs.Config
import qs.Modules

ListView {
    id: root

    maximumFlickVelocity: 3000

    rebound: Transition {
        Anim {
            properties: "x,y"
        }
    }
}
