import qs.Config

CustomText {
    property real fill
    property int grade: DynamicColors.light ? 0 : -25

    font.family: "Material Symbols Rounded"
    font.pointSize: 15
    font.variableAxes: ({
            FILL: fill.toFixed(1),
            GRAD: grade,
            opsz: fontInfo.pixelSize,
            wght: fontInfo.weight
        })
}
