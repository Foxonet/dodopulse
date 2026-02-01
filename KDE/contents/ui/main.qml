import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

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
    property real netTotalIn: 0
    property real netTotalOut: 0
    property string localIP: "—"
    property string publicIP: "Fetching..."
    property int uptime: 0
    property real loadAvg1: 0
    property real loadAvg5: 0
    property real loadAvg15: 0
    property string kernelVersion: ""
    property int cpuCores: 0
    property string cpuModel: ""
    property int processCount: 0
    
    // GPU
    property real gpuUsage: 0
    property real gpuTemp: 0
    property string gpuName: "—"
    
    // Battery
    property bool hasBattery: false
    property real batteryLevel: 0
    property bool batteryCharging: false
    property string batteryStatus: ""
    
    // Temperature
    property real cpuTemp: 0

    // History arrays
    property var cpuHistory: []
    property var memHistory: []
    property var gpuHistory: []
    property var netHistory: []

    // Previous values
    property real prevCpuTotal: 0
    property real prevCpuBusy: 0
    property real prevNetIn: 0
    property real prevNetOut: 0
    property var prevTime: null

    // Colors
    readonly property color cpuColor: "#5B8DEF"
    readonly property color memColor: "#FF7359"
    readonly property color gpuColor: "#F25990"
    readonly property color netColor: "#40E68D"
    readonly property color netUpColor: "#B266FF"
    readonly property color diskColor: "#F2A60F"
    readonly property color battColor: "#4DE680"
    readonly property color tempColor: "#FF9933"
    readonly property color warningColor: "#FFBF33"
    readonly property color dangerColor: "#FF5959"
    readonly property color systemColor: "#9980E6"

    toolTipMainText: "DodoPulse"
    toolTipSubText: "CPU: " + cpuUsage.toFixed(0) + "% | RAM: " + memUsage.toFixed(0) + "%"

    compactRepresentation: MouseArea {
        Layout.minimumWidth: compactRow.implicitWidth + 8
        Layout.preferredWidth: compactRow.implicitWidth + 8
        Layout.minimumHeight: Kirigami.Units.iconSizes.medium
        
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        RowLayout {
            id: compactRow
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
                Layout.preferredWidth: 4; Layout.preferredHeight: 18; radius: 2
                color: Qt.rgba(cpuColor.r, cpuColor.g, cpuColor.b, 0.3)
                Rectangle {
                    anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                    height: parent.height * Math.min(cpuUsage / 100, 1); radius: 2
                    color: cpuUsage > 90 ? dangerColor : (cpuUsage > 70 ? warningColor : cpuColor)
                }
            }
            PlasmaComponents.Label { text: cpuUsage.toFixed(0) + "%"; font.pixelSize: 11; font.family: "monospace" }

            Rectangle {
                Layout.preferredWidth: 4; Layout.preferredHeight: 18; radius: 2
                color: Qt.rgba(memColor.r, memColor.g, memColor.b, 0.3)
                Rectangle {
                    anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                    height: parent.height * Math.min(memUsage / 100, 1); radius: 2
                    color: memUsage > 90 ? dangerColor : (memUsage > 75 ? warningColor : memColor)
                }
            }
            PlasmaComponents.Label { text: memUsage.toFixed(0) + "%"; font.pixelSize: 11; font.family: "monospace" }
        }
    }

    fullRepresentation: Rectangle {
        id: popup
        
        // Calculate height based on content
        readonly property int cardHeight: 68
        readonly property int networkCardHeight: 85
        readonly property int headerHeight: 30
        readonly property int spacing: 8
        readonly property int margins: 28
        readonly property int baseCards: 6  // CPU, Memory, GPU, Network, Disk, System
        readonly property int batteryCards: hasBattery ? 1 : 0
        
        Layout.preferredWidth: 350
        Layout.preferredHeight: headerHeight + (baseCards * cardHeight) + networkCardHeight - cardHeight + (batteryCards * cardHeight) + ((baseCards + batteryCards) * spacing) + margins
        Layout.minimumWidth: 340
        Layout.minimumHeight: Layout.preferredHeight
        
        color: Kirigami.Theme.backgroundColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
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
                Layout.preferredHeight: 68
                radius: 10
                color: Qt.rgba(cpuColor.r, cpuColor.g, cpuColor.b, 0.1)
                border.color: Qt.rgba(cpuColor.r, cpuColor.g, cpuColor.b, 0.3)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ColumnLayout {
                        spacing: 2
                        RowLayout {
                            spacing: 6
                            PlasmaComponents.Label {
                                text: cpuUsage.toFixed(1) + "%"
                                font.pixelSize: 22
                                font.bold: true
                                color: cpuUsage > 90 ? dangerColor : (cpuUsage > 70 ? warningColor : cpuColor)
                            }
                            Rectangle {
                                visible: cpuTemp > 0
                                width: cpuTempText.implicitWidth + 10
                                height: 20
                                radius: 5
                                color: Qt.rgba(tempColor.r, tempColor.g, tempColor.b, 0.15)
                                PlasmaComponents.Label {
                                    id: cpuTempText
                                    anchors.centerIn: parent
                                    text: cpuTemp.toFixed(0) + "°C"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: cpuTemp > 85 ? dangerColor : (cpuTemp > 70 ? warningColor : tempColor)
                                }
                            }
                        }
                        PlasmaComponents.Label { text: "CPU"; font.pixelSize: 10; opacity: 0.7 }
                        PlasmaComponents.Label {
                            text: cpuModel || (cpuCores + " cores")
                            font.pixelSize: 9; opacity: 0.5
                            Layout.maximumWidth: 140; elide: Text.ElideRight
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Canvas {
                        id: cpuCanvas
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 48
                        onPaint: drawGraph(getContext("2d"), cpuHistory, cpuColor, width, height)
                    }
                }
            }

            // Memory Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                radius: 10
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
                        PlasmaComponents.Label { text: "Memory"; font.pixelSize: 10; opacity: 0.7 }
                        PlasmaComponents.Label {
                            text: memUsedGB.toFixed(1) + " / " + memTotalGB.toFixed(0) + " GB"
                            font.pixelSize: 9; opacity: 0.5
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Canvas {
                        id: memCanvas
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 48
                        onPaint: drawGraph(getContext("2d"), memHistory, memColor, width, height)
                    }
                }
            }

            // GPU Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                radius: 10
                color: Qt.rgba(gpuColor.r, gpuColor.g, gpuColor.b, 0.1)
                border.color: Qt.rgba(gpuColor.r, gpuColor.g, gpuColor.b, 0.3)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ColumnLayout {
                        spacing: 2
                        RowLayout {
                            spacing: 6
                            PlasmaComponents.Label {
                                text: gpuUsage.toFixed(0) + "%"
                                font.pixelSize: 22
                                font.bold: true
                                color: gpuColor
                            }
                            Rectangle {
                                visible: gpuTemp > 0
                                width: gpuTempText.implicitWidth + 10
                                height: 20
                                radius: 5
                                color: Qt.rgba(tempColor.r, tempColor.g, tempColor.b, 0.15)
                                PlasmaComponents.Label {
                                    id: gpuTempText
                                    anchors.centerIn: parent
                                    text: gpuTemp.toFixed(0) + "°C"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: gpuTemp > 85 ? dangerColor : (gpuTemp > 70 ? warningColor : tempColor)
                                }
                            }
                        }
                        PlasmaComponents.Label { text: "GPU"; font.pixelSize: 10; opacity: 0.7 }
                        PlasmaComponents.Label {
                            text: gpuName
                            font.pixelSize: 9; opacity: 0.5
                            Layout.maximumWidth: 140; elide: Text.ElideRight
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Canvas {
                        id: gpuCanvas
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 48
                        onPaint: drawGraph(getContext("2d"), gpuHistory, gpuColor, width, height)
                    }
                }
            }

            // Network Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 85
                radius: 10
                color: Qt.rgba(netColor.r, netColor.g, netColor.b, 0.1)
                border.color: Qt.rgba(netColor.r, netColor.g, netColor.b, 0.3)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    ColumnLayout {
                        spacing: 2
                        PlasmaComponents.Label { text: "Network"; font.pixelSize: 10; opacity: 0.7 }
                        RowLayout {
                            spacing: 4
                            PlasmaComponents.Label { text: "↓"; font.pixelSize: 14; font.bold: true; color: netColor }
                            PlasmaComponents.Label { text: formatSpeed(netIn); font.pixelSize: 12; font.bold: true; color: netColor }
                        }
                        RowLayout {
                            spacing: 4
                            PlasmaComponents.Label { text: "↑"; font.pixelSize: 14; font.bold: true; color: netUpColor }
                            PlasmaComponents.Label { text: formatSpeed(netOut); font.pixelSize: 12; font.bold: true; color: netUpColor }
                        }
                        PlasmaComponents.Label {
                            text: "Session: ↓" + formatBytes(netTotalIn) + " ↑" + formatBytes(netTotalOut)
                            font.pixelSize: 8; opacity: 0.5
                        }
                    }
                    Item { Layout.fillWidth: true }
                    ColumnLayout {
                        spacing: 1
                        PlasmaComponents.Label { text: "Local: " + localIP; font.pixelSize: 8; opacity: 0.6; Layout.alignment: Qt.AlignRight }
                        PlasmaComponents.Label { text: "Public: " + publicIP; font.pixelSize: 8; opacity: 0.6; Layout.alignment: Qt.AlignRight }
                        Canvas {
                            id: netCanvas
                            Layout.preferredWidth: 85
                            Layout.preferredHeight: 38
                            onPaint: drawGraph(getContext("2d"), netHistory, netColor, width, height)
                        }
                    }
                }
            }

            // Disk Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                radius: 10
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
                            font.pixelSize: 18; font.bold: true
                            color: diskUsage > 90 ? dangerColor : (diskUsage > 75 ? warningColor : diskColor)
                        }
                        PlasmaComponents.Label { text: "Disk"; font.pixelSize: 10; opacity: 0.7 }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label {
                            text: diskFreeGB.toFixed(0) + " GB free of " + diskTotalGB.toFixed(0) + " GB"
                            font.pixelSize: 9; opacity: 0.6
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 6; radius: 3
                        color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
                        Rectangle {
                            width: parent.width * Math.min(diskUsage / 100, 1)
                            height: parent.height; radius: 3
                            color: diskUsage > 90 ? dangerColor : (diskUsage > 75 ? warningColor : diskColor)
                        }
                    }
                }
            }

            // Battery Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                radius: 10
                visible: hasBattery
                color: Qt.rgba(battColor.r, battColor.g, battColor.b, 0.1)
                border.color: Qt.rgba(battColor.r, battColor.g, battColor.b, 0.3)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        PlasmaComponents.Label {
                            text: batteryLevel.toFixed(0) + "%"
                            font.pixelSize: 18; font.bold: true
                            color: batteryCharging ? "#60A5FA" : (batteryLevel < 20 ? dangerColor : battColor)
                        }
                        PlasmaComponents.Label { text: batteryCharging ? "Charging" : "Battery"; font.pixelSize: 10; opacity: 0.7 }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label { text: batteryStatus; font.pixelSize: 9; opacity: 0.6 }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 6; radius: 3
                        color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
                        Rectangle {
                            width: parent.width * Math.min(batteryLevel / 100, 1)
                            height: parent.height; radius: 3
                            color: batteryCharging ? "#60A5FA" : (batteryLevel < 20 ? dangerColor : battColor)
                        }
                    }
                }
            }

            // System Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 10
                color: Qt.rgba(systemColor.r, systemColor.g, systemColor.b, 0.1)
                border.color: Qt.rgba(systemColor.r, systemColor.g, systemColor.b, 0.3)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    RowLayout {
                        PlasmaComponents.Label { text: "System"; font.pixelSize: 10; opacity: 0.7 }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label { text: "Processes: " + processCount; font.pixelSize: 9; opacity: 0.6 }
                    }
                    RowLayout {
                        PlasmaComponents.Label {
                            text: "Load: " + loadAvg1.toFixed(2) + "  " + loadAvg5.toFixed(2) + "  " + loadAvg15.toFixed(2)
                            font.pixelSize: 10; color: systemColor
                        }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label { text: "Kernel: " + kernelVersion; font.pixelSize: 9; opacity: 0.5 }
                    }
                }
            }
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
                parseCpuStat(stdout); cpuCanvas.requestPaint()
            } else if (sourceName.indexOf("cat /proc/meminfo") !== -1) {
                parseMemInfo(stdout); memCanvas.requestPaint()
            } else if (sourceName.indexOf("df -B1 /") !== -1) {
                parseDiskInfo(stdout)
            } else if (sourceName.indexOf("cat /proc/net/dev") !== -1) {
                parseNetInfo(stdout); netCanvas.requestPaint()
            } else if (sourceName.indexOf("cat /proc/uptime") !== -1) {
                parseUptime(stdout)
            } else if (sourceName.indexOf("cat /proc/loadavg") !== -1) {
                parseLoadAvg(stdout)
            } else if (sourceName.indexOf("uname -r") !== -1) {
                kernelVersion = stdout.trim()
            } else if (sourceName.indexOf("nproc") !== -1) {
                cpuCores = parseInt(stdout.trim()) || 0
            } else if (sourceName.indexOf("lscpu") !== -1) {
                parseCpuModel(stdout)
            } else if (sourceName.indexOf("nvidia-smi") !== -1) {
                parseNvidiaGpu(stdout); gpuCanvas.requestPaint()
            } else if (sourceName.indexOf("gpu_busy_percent") !== -1) {
                parseAmdGpu(stdout); gpuCanvas.requestPaint()
            } else if (sourceName.indexOf("intel_gpu_top") !== -1 || sourceName.indexOf("gt_cur_freq") !== -1) {
                parseIntelGpu(stdout); gpuCanvas.requestPaint()
            } else if (sourceName.indexOf("BAT") !== -1) {
                parseBattery(stdout)
            } else if (sourceName.indexOf("hwmon") !== -1 || sourceName.indexOf("thermal") !== -1) {
                parseTemperature(stdout, sourceName)
            } else if (sourceName.indexOf("ip -4 addr") !== -1) {
                parseLocalIP(stdout)
            } else if (sourceName.indexOf("curl") !== -1 || sourceName.indexOf("ipify") !== -1) {
                publicIP = stdout.trim() || "—"
            } else if (sourceName.indexOf("glxinfo") !== -1) {
                parseGpuName(stdout)
            }
            
            disconnectSource(sourceName)
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: updateMetrics()
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: updateSlowMetrics()
    }

    Component.onCompleted: {
        for (var i = 0; i < 60; i++) {
            cpuHistory.push(0); memHistory.push(0); gpuHistory.push(0); netHistory.push(0)
        }
        execSource.connectSource("uname -r")
        execSource.connectSource("nproc")
        execSource.connectSource("lscpu | grep 'Model name' | head -1")
        execSource.connectSource("glxinfo 2>/dev/null | grep 'OpenGL renderer' | head -1")
        execSource.connectSource("curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo '—'")
        updateMetrics()
        updateSlowMetrics()
    }

    function updateMetrics() {
        execSource.connectSource("cat /proc/stat")
        execSource.connectSource("cat /proc/meminfo")
        execSource.connectSource("cat /proc/net/dev")
        execSource.connectSource("cat /proc/uptime")
        execSource.connectSource("cat /proc/loadavg")
        
        // GPU - try multiple methods
        execSource.connectSource("nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo ''")
        execSource.connectSource("cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo ''")
    }

    function updateSlowMetrics() {
        execSource.connectSource("df -B1 / | tail -1")
        execSource.connectSource("ip -4 addr show | grep inet | grep -v '127.0.0.1' | head -1")
        execSource.connectSource("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; echo '---'; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1; echo '---'; cat /sys/class/power_supply/AC*/online 2>/dev/null || cat /sys/class/power_supply/ADP*/online 2>/dev/null || echo '0'")
        execSource.connectSource("cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1")
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
                    if (totalDelta > 0) cpuUsage = (busyDelta / totalDelta) * 100
                }
                prevCpuTotal = total; prevCpuBusy = busy
                cpuHistory = cpuHistory.slice(1).concat([cpuUsage])
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
            if (line.indexOf("MemTotal:") === 0) memTotal = parseInt(line.split(/\s+/)[1]) || 0
            else if (line.indexOf("MemAvailable:") === 0) memAvailable = parseInt(line.split(/\s+/)[1]) || 0
        }
        if (memTotal > 0) {
            var memUsed = memTotal - memAvailable
            memUsage = (memUsed / memTotal) * 100
            memUsedGB = memUsed / (1024 * 1024)
            memTotalGB = memTotal / (1024 * 1024)
            memHistory = memHistory.slice(1).concat([memUsage])
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
        netTotalIn = totalIn; netTotalOut = totalOut
        prevNetIn = totalIn; prevNetOut = totalOut; prevTime = now
        netHistory = netHistory.slice(1).concat([netIn + netOut])
    }

    function parseUptime(content) { if (content) uptime = parseInt(content.split(' ')[0]) || 0 }

    function parseLoadAvg(content) {
        if (!content) return
        var parts = content.split(' ')
        loadAvg1 = parseFloat(parts[0]) || 0
        loadAvg5 = parseFloat(parts[1]) || 0
        loadAvg15 = parseFloat(parts[2]) || 0
        if (parts.length >= 4) {
            var procParts = parts[3].split('/')
            if (procParts.length >= 2) processCount = parseInt(procParts[1]) || 0
        }
    }

    function parseCpuModel(content) {
        if (!content) return
        var match = content.match(/Model name:\s*(.+)/)
        if (match) cpuModel = match[1].trim().replace(/\s+/g, ' ').substring(0, 35)
    }

    function parseNvidiaGpu(content) {
        if (!content || content.trim() === '') return
        var parts = content.trim().split(',')
        if (parts.length >= 1 && parts[0].trim() !== '') {
            gpuUsage = parseFloat(parts[0].trim()) || 0
            if (gpuName === "—") gpuName = "NVIDIA GPU"
        }
        if (parts.length >= 2) gpuTemp = parseFloat(parts[1].trim()) || 0
        gpuHistory = gpuHistory.slice(1).concat([gpuUsage])
    }

    function parseAmdGpu(content) {
        if (!content || content.trim() === '') return
        var usage = parseInt(content.trim())
        if (!isNaN(usage)) {
            gpuUsage = usage
            if (gpuName === "—") gpuName = "AMD GPU"
            gpuHistory = gpuHistory.slice(1).concat([gpuUsage])
        }
    }

    function parseIntelGpu(content) {
        if (!content || content.trim() === '') return
        // Intel GPU doesn't have easy usage metrics, just update history
        gpuHistory = gpuHistory.slice(1).concat([gpuUsage])
    }

    function parseGpuName(content) {
        if (!content) return
        var match = content.match(/OpenGL renderer string:\s*(.+)/)
        if (match) {
            var name = match[1].trim()
            // Clean up the name
            name = name.replace(/Mesa\s*/i, '').replace(/\(.*\)/, '').trim()
            if (name.length > 25) name = name.substring(0, 25) + "..."
            gpuName = name
        }
    }

    function parseBattery(content) {
        if (!content || content.trim() === '' || content.indexOf('---') === 0) {
            hasBattery = false; return
        }
        var parts = content.split('---')
        var capacity = 0
        var status = ""
        var acOnline = false
        
        if (parts.length >= 1 && parts[0].trim() !== '') {
            capacity = parseInt(parts[0].trim())
            if (!isNaN(capacity)) { hasBattery = true; batteryLevel = capacity }
        }
        if (parts.length >= 2 && parts[1].trim() !== '') {
            status = parts[1].trim()
        }
        if (parts.length >= 3 && parts[2].trim() !== '') {
            acOnline = parts[2].trim() === "1"
        }
        
        // Determine charging status based on AC and battery status
        if (status === "Charging") {
            batteryCharging = true
            batteryStatus = "Charging"
        } else if (status === "Full") {
            batteryCharging = false
            batteryStatus = "Fully charged"
        } else if (status === "Not charging" && acOnline) {
            batteryCharging = false
            batteryStatus = "Plugged in"
        } else if (status === "Discharging" || !acOnline) {
            batteryCharging = false
            batteryStatus = "On battery"
        } else {
            batteryCharging = false
            batteryStatus = status || "Unknown"
        }
    }

    function parseTemperature(content, source) {
        if (!content) return
        var temp = parseInt(content.trim())
        if (!isNaN(temp)) {
            if (temp > 1000) temp = temp / 1000
            if (temp > 0 && temp < 150) cpuTemp = temp
        }
    }

    function parseLocalIP(content) {
        if (!content) return
        var match = content.match(/inet\s+(\d+\.\d+\.\d+\.\d+)/)
        if (match) localIP = match[1]
    }

    function formatSpeed(bps) {
        if (bps < 1024) return bps.toFixed(0) + " B/s"
        if (bps < 1024 * 1024) return (bps / 1024).toFixed(1) + " KB/s"
        return (bps / (1024 * 1024)).toFixed(2) + " MB/s"
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB"
    }

    function formatUptime(seconds) {
        var d = Math.floor(seconds / 86400)
        var h = Math.floor((seconds % 86400) / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        if (d > 0) return d + "d " + h + "h " + m + "m"
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

        // Fill
        ctx.beginPath()
        ctx.moveTo(0, h)
        for (var i = 0; i < values.length; i++) {
            ctx.lineTo((i / (values.length - 1)) * w, h - (values[i] / maxVal) * h * 0.85 - 2)
        }
        ctx.lineTo(w, h)
        ctx.closePath()
        var gradient = ctx.createLinearGradient(0, 0, 0, h)
        gradient.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0.4))
        gradient.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0.05))
        ctx.fillStyle = gradient
        ctx.fill()

        // Line
        ctx.beginPath()
        ctx.strokeStyle = color
        ctx.lineWidth = 1.5
        for (var j = 0; j < values.length; j++) {
            var x = (j / (values.length - 1)) * w
            var y = h - (values[j] / maxVal) * h * 0.85 - 2
            if (j === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
        }
        ctx.stroke()

        // Dot
        ctx.beginPath()
        ctx.arc(w - 2, h - (values[values.length - 1] / maxVal) * h * 0.85 - 2, 2.5, 0, Math.PI * 2)
        ctx.fillStyle = color
        ctx.fill()
    }
}
