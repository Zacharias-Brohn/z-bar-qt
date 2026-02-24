import Quickshell
import QtQuick

ShaderEffect {
	required property Item maskSource
	required property Item source

	fragmentShader: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/shaders/opacitymask.frag.qsb`)
}
