import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Important: Start with compact view, expand on click
    preferredRepresentation: compactRepresentation
    
    // System metrics
    property real cpuUsage: 0
    property real memUsage: 0
    property real memUsedGB: 0
    property real memTotalGB: 0
    property real diskUsage: 0
    property real diskFreeGB: 0
    property real diskTotalGB: 0
    property real netIn: 0
    property real netOut: 0
    property int uptime: 0
    property real loadAvg1: 0
    property real loadAvg5: 0
    property real loadAvg15: 0
    property string kernelVersion: ""
    property int cpuCores: 0

    // History arrays
    property var cpuHistory: []
    property var memHistory: []

    // Previous values for calculations
    property real prevCpuTotal: 0
    property real prevCpuBusy: 0
    property real prevNetIn: 0
    property real prevNetOut: 0
    property var prevTime: null

    // Colors
    readonly property color cpuColor: "#5B8DEF"
    readonly property color memColor: "#FF7359"
    readonly property color netColor: "#40E68D"
    readonly property color netUpColor: "#B266FF"
    readonly property color diskColor: "#F2A60F"
    readonly property color warningColor: "#FFBF33"
    readonly property color dangerColor: "#FF5959"

    toolTipMainText: "DodoPulse"
    toolTipSubText: "CPU: " + cpuUsage.toFixed(0) + "% | RAM: " + memUsage.toFixed(0) + "%"

    // Compact representation - shows in panel
    compactRepresentation: MouseArea {
        id: compactRoot
        
        Layout.minimumWidth: row.implicitWidth + 8
        Layout.preferredWidth: row.implicitWidth + 8
        Layout.minimumHeight: Kirigami.Units.iconSizes.medium
        
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        
        onClicked: {
            root.expanded = !root.expanded
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 4

            // CPU icon/bar
            Rectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: 18
                radius: 2
                color: Qt.rgba(cpuColor.r, cpuColor.g, cpuColor.b, 0.3)

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * Math.min(cpuUsage / 100, 1)
                    radius: 2
                    color: cpuUsage > 90 ? dangerColor : (cpuUsage > 70 ? warningColor : cpuColor)
                    
                    Behavior on height { NumberAnimation { duration: 200 } }
                }
            }

            // CPU text
            PlasmaComponents.Label {
                text: cpuUsage.toFixed(0) + "%"
                font.pixelSize: 11
                font.family: "monospace"
                color: cpuUsage > 90 ? dangerColor : (cpuUsage > 70 ? warningColor : Kirigami.Theme.textColor)
            }

            // Memory icon/bar
            Rectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: 18
                radius: 2
                color: Qt.rgba(memColor.r, memColor.g, memColor.b, 0.3)

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * Math.min(memUsage / 100, 1)
                    radius: 2
                    color: memUsage > 90 ? dangerColor : (memUsage > 75 ? warningColor : memColor)
                    
                    Behavior on height { NumberAnimation { duration: 200 } }
                }
            }

            // Memory text
            PlasmaComponents.Label {
                text: memUsage.toFixed(0) + "%"
                font.pixelSize: 11
                font.family: "monospace"
                color: memUsage > 90 ? dangerColor : (memUsage > 75 ? warningColor : Kirigami.Theme.textColor)
            }
        }
    }

    // Full representation - popup when clicked
    fullRepresentation: Rectangle {
        Layout.preferredWidth: 340
        Layout.preferredHeight: 420
        Layout.minimumWidth: 300
        Layout.minimumHeight: 380
        
        color: Kirigami.Theme.backgroundColor
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    text: "DodoPulse"
                    font.pixelSize: 16
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents.Label {
                    text: "↑ " + formatUptime(uptime)
                    font.pixelSize: 10
                    opacity: 0.7
                }
            }

            // CPU Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 8
                color: Qt.rgba(cpuColor.r, cpuColor.g, cpuColor.b, 0.1)
                border.color: Qt.rgba(cpuColor.r, cpuColor.g, cpuColor.b, 0.3)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ColumnLayout {
                        spacing: 2
                        PlasmaComponents.Label {
                            text: cpuUsage.toFixed(1) + "%"
                            font.pixelSize: 22
                            font.bold: true
                            color: cpuUsage > 90 ? dangerColor : (cpuUsage > 70 ? warningColor : cpuColor)
                        }
                        PlasmaComponents.Label {
                            text: "CPU • " + cpuCores + " cores"
                            font.pixelSize: 10
                            opacity: 0.7
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Canvas {
                        id: cpuCanvas
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 45
                        onPaint: drawGraph(getContext("2d"), cpuHistory, cpuColor, width, height)
                    }
                }
            }

            // Memory Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 8
                color: Qt.rgba(memColor.r, memColor.g, memColor.b, 0.1)
                border.color: Qt.rgba(memColor.r, memColor.g, memColor.b, 0.3)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ColumnLayout {
                        spacing: 2
                        PlasmaComponents.Label {
                            text: memUsage.toFixed(1) + "%"
                            font.pixelSize: 22
                            font.bold: true
                            color: memUsage > 90 ? dangerColor : (memUsage > 75 ? warningColor : memColor)
                        }
                        PlasmaComponents.Label {
                            text: "Memory • " + memUsedGB.toFixed(1) + "/" + memTotalGB.toFixed(0) + " GB"
                            font.pixelSize: 10
                            opacity: 0.7
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Canvas {
                        id: memCanvas
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 45
                        onPaint: drawGraph(getContext("2d"), memHistory, memColor, width, height)
                    }
                }
            }

            // Network Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                radius: 8
                color: Qt.rgba(netColor.r, netColor.g, netColor.b, 0.1)
                border.color: Qt.rgba(netColor.r, netColor.g, netColor.b, 0.3)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 16

                    ColumnLayout {
                        spacing: 2
                        RowLayout {
                            spacing: 6
                            PlasmaComponents.Label { text: "↓"; font.pixelSize: 14; font.bold: true; color: netColor }
                            PlasmaComponents.Label { text: formatSpeed(netIn); font.pixelSize: 12; font.bold: true; color: netColor }
                        }
                        RowLayout {
                            spacing: 6
                            PlasmaComponents.Label { text: "↑"; font.pixelSize: 14; font.bold: true; color: netUpColor }
                            PlasmaComponents.Label { text: formatSpeed(netOut); font.pixelSize: 12; font.bold: true; color: netUpColor }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    PlasmaComponents.Label {
                        text: "Network"
                        font.pixelSize: 10
                        opacity: 0.7
                    }
                }
            }

            // Disk Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 8
                color: Qt.rgba(diskColor.r, diskColor.g, diskColor.b, 0.1)
                border.color: Qt.rgba(diskColor.r, diskColor.g, diskColor.b, 0.3)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        PlasmaComponents.Label {
                            text: diskUsage.toFixed(0) + "%"
                            font.pixelSize: 16
                            font.bold: true
                            color: diskUsage > 90 ? dangerColor : (diskUsage > 75 ? warningColor : diskColor)
                        }
                        PlasmaComponents.Label {
                            text: "Disk • " + diskFreeGB.toFixed(0) + " GB free"
                            font.pixelSize: 10
                            opacity: 0.7
                        }
                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 5
                        radius: 2
                        color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
                        Rectangle {
                            width: parent.width * Math.min(diskUsage / 100, 1)
                            height: parent.height
                            radius: 2
                            color: diskUsage > 90 ? dangerColor : (diskUsage > 75 ? warningColor : diskColor)
                        }
                    }
                }
            }

            // System Info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: Qt.rgba(0.5, 0.5, 0.5, 0.1)
                border.color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    PlasmaComponents.Label {
                        text: "Load: " + loadAvg1.toFixed(2) + " " + loadAvg5.toFixed(2) + " " + loadAvg15.toFixed(2)
                        font.pixelSize: 10
                    }
                    Item { Layout.fillWidth: true }
                    PlasmaComponents.Label {
                        text: kernelVersion
                        font.pixelSize: 10
                        opacity: 0.7
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Data source
    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        
        onNewData: function(sourceName, data) {
            var stdout = data["stdout"]
            
            if (sourceName.indexOf("cat /proc/stat") !== -1) {
                parseCpuStat(stdout)
                cpuCanvas.requestPaint()
            } else if (sourceName.indexOf("cat /proc/meminfo") !== -1) {
                parseMemInfo(stdout)
                memCanvas.requestPaint()
            } else if (sourceName.indexOf("df -B1 /") !== -1) {
                parseDiskInfo(stdout)
            } else if (sourceName.indexOf("cat /proc/net/dev") !== -1) {
                parseNetInfo(stdout)
            } else if (sourceName.indexOf("cat /proc/uptime") !== -1) {
                parseUptime(stdout)
            } else if (sourceName.indexOf("cat /proc/loadavg") !== -1) {
                parseLoadAvg(stdout)
            } else if (sourceName.indexOf("uname -r") !== -1) {
                kernelVersion = stdout.trim()
            } else if (sourceName.indexOf("nproc") !== -1) {
                cpuCores = parseInt(stdout.trim()) || 0
            }
            
            disconnectSource(sourceName)
        }
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateMetrics()
    }

    Component.onCompleted: {
        for (var i = 0; i < 60; i++) {
            cpuHistory.push(0)
            memHistory.push(0)
        }
        execSource.connectSource("uname -r")
        execSource.connectSource("nproc")
        updateMetrics()
    }

    function updateMetrics() {
        execSource.connectSource("cat /proc/stat")
        execSource.connectSource("cat /proc/meminfo")
        execSource.connectSource("df -B1 / | tail -1")
        execSource.connectSource("cat /proc/net/dev")
        execSource.connectSource("cat /proc/uptime")
        execSource.connectSource("cat /proc/loadavg")
    }

    function parseCpuStat(content) {
        if (!content) return
        var lines = content.split('\n')
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf("cpu ") === 0) {
                var parts = lines[i].split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0

                var total = user + nice + system + idle + iowait + irq + softirq
                var busy = user + nice + system + irq + softirq

                if (prevCpuTotal > 0) {
                    var totalDelta = total - prevCpuTotal
                    var busyDelta = busy - prevCpuBusy
                    if (totalDelta > 0) {
                        cpuUsage = (busyDelta / totalDelta) * 100
                    }
                }

                prevCpuTotal = total
                prevCpuBusy = busy
                
                var newHistory = cpuHistory.slice(1)
                newHistory.push(cpuUsage)
                cpuHistory = newHistory
                break
            }
        }
    }

    function parseMemInfo(content) {
        if (!content) return
        var memTotal = 0, memAvailable = 0
        var lines = content.split('\n')
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (line.indexOf("MemTotal:") === 0) {
                memTotal = parseInt(line.split(/\s+/)[1]) || 0
            } else if (line.indexOf("MemAvailable:") === 0) {
                memAvailable = parseInt(line.split(/\s+/)[1]) || 0
            }
        }
        if (memTotal > 0) {
            var memUsed = memTotal - memAvailable
            memUsage = (memUsed / memTotal) * 100
            memUsedGB = memUsed / (1024 * 1024)
            memTotalGB = memTotal / (1024 * 1024)
            
            var newHistory = memHistory.slice(1)
            newHistory.push(memUsage)
            memHistory = newHistory
        }
    }

    function parseDiskInfo(content) {
        if (!content) return
        var parts = content.trim().split(/\s+/)
        if (parts.length >= 4) {
            var total = parseInt(parts[1]) || 0
            var used = parseInt(parts[2]) || 0
            var available = parseInt(parts[3]) || 0
            if (total > 0) {
                diskUsage = (used / total) * 100
                diskTotalGB = total / (1024 * 1024 * 1024)
                diskFreeGB = available / (1024 * 1024 * 1024)
            }
        }
    }

    function parseNetInfo(content) {
        if (!content) return
        var totalIn = 0, totalOut = 0
        var lines = content.split('\n')
        for (var i = 2; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line || line.indexOf("lo:") === 0) continue
            var parts = line.split(/\s+/)
            if (parts.length >= 10) {
                totalIn += parseInt(parts[1]) || 0
                totalOut += parseInt(parts[9]) || 0
            }
        }
        
        var now = Date.now()
        if (prevTime !== null) {
            var timeDelta = (now - prevTime) / 1000
            if (timeDelta > 0) {
                netIn = Math.max(0, (totalIn - prevNetIn) / timeDelta)
                netOut = Math.max(0, (totalOut - prevNetOut) / timeDelta)
            }
        }
        prevNetIn = totalIn
        prevNetOut = totalOut
        prevTime = now
    }

    function parseUptime(content) {
        if (!content) return
        uptime = parseInt(content.split(' ')[0]) || 0
    }

    function parseLoadAvg(content) {
        if (!content) return
        var parts = content.split(' ')
        loadAvg1 = parseFloat(parts[0]) || 0
        loadAvg5 = parseFloat(parts[1]) || 0
        loadAvg15 = parseFloat(parts[2]) || 0
    }

    function formatSpeed(bps) {
        if (bps < 1024) return bps.toFixed(0) + " B/s"
        if (bps < 1024 * 1024) return (bps / 1024).toFixed(1) + " KB/s"
        return (bps / (1024 * 1024)).toFixed(2) + " MB/s"
    }

    function formatUptime(seconds) {
        var d = Math.floor(seconds / 86400)
        var h = Math.floor((seconds % 86400) / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        if (d > 0) return d + "d " + h + "h"
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

    function drawGraph(ctx, values, color, w, h) {
        if (!ctx || !values || values.length < 2) return
        
        ctx.reset()
        
        var maxVal = Math.max.apply(null, values)
        if (maxVal < 1) maxVal = 100

        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.1)
        ctx.fillRect(0, 0, w, h)

        ctx.beginPath()
        ctx.strokeStyle = color
        ctx.lineWidth = 1.5
        
        for (var i = 0; i < values.length; i++) {
            var x = (i / (values.length - 1)) * w
            var y = h - (values[i] / maxVal) * h * 0.85 - 3
            if (i === 0) ctx.moveTo(x, y)
            else ctx.lineTo(x, y)
        }
        ctx.stroke()
    }
}
