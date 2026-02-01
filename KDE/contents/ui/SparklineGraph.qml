import QtQuick 2.15

Canvas {
    id: sparkline

    property var values: []
    property color color: "#5B8DEF"
    property real lineWidth: 1.5

    onValuesChanged: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()

        if (!values || values.length < 2) return

        var w = width
        var h = height
        var padding = 4

        // Find max value for scaling
        var maxVal = Math.max.apply(null, values)
        if (maxVal < 1) maxVal = 100  // Default scale for percentage

        // Draw background
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.1)
        ctx.beginPath()
        roundRect(ctx, 0, 0, w, h, 6)
        ctx.fill()

        // Calculate points
        var points = []
        var xStep = (w - padding * 2) / (values.length - 1)
        
        for (var i = 0; i < values.length; i++) {
            var x = padding + i * xStep
            var normalizedValue = Math.min(values[i] / maxVal, 1)
            var y = h - padding - normalizedValue * (h - padding * 2)
            points.push({x: x, y: y})
        }

        // Draw filled area
        ctx.beginPath()
        ctx.moveTo(points[0].x, h - padding)
        for (var j = 0; j < points.length; j++) {
            ctx.lineTo(points[j].x, points[j].y)
        }
        ctx.lineTo(points[points.length - 1].x, h - padding)
        ctx.closePath()

        // Gradient fill
        var gradient = ctx.createLinearGradient(0, 0, 0, h)
        gradient.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0.4))
        gradient.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0.05))
        ctx.fillStyle = gradient
        ctx.fill()

        // Draw line with glow
        ctx.beginPath()
        ctx.moveTo(points[0].x, points[0].y)
        for (var k = 1; k < points.length; k++) {
            ctx.lineTo(points[k].x, points[k].y)
        }
        
        // Glow effect
        ctx.strokeStyle = Qt.rgba(color.r, color.g, color.b, 0.4)
        ctx.lineWidth = lineWidth + 2
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        ctx.stroke()

        // Main line
        ctx.strokeStyle = color
        ctx.lineWidth = lineWidth
        ctx.stroke()

        // Draw end point dot
        if (points.length > 0) {
            var lastPoint = points[points.length - 1]
            ctx.beginPath()
            ctx.arc(lastPoint.x, lastPoint.y, 3, 0, Math.PI * 2)
            ctx.fillStyle = color
            ctx.fill()
        }
    }

    function roundRect(ctx, x, y, width, height, radius) {
        ctx.moveTo(x + radius, y)
        ctx.lineTo(x + width - radius, y)
        ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
        ctx.lineTo(x + width, y + height - radius)
        ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
        ctx.lineTo(x + radius, y + height)
        ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
        ctx.lineTo(x, y + radius)
        ctx.quadraticCurveTo(x, y, x + radius, y)
    }
}
