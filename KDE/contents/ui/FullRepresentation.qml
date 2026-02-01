import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: fullRoot

    // Metrics properties
    property real cpuUsage: 0
    property real memUsage: 0
    property real memUsedGB: 0
    property real memTotalGB: 0
    property real diskUsage: 0
    property real diskFreeGB: 0
    property real diskTotalGB: 0
    property real netIn: 0
    property real netOut: 0
    property real gpuUsage: 0
    property real cpuTemp: 0
    property real gpuTemp: 0
    property string cpuModel: ""
    property string gpuModel: ""
    property int cpuCores: 0
    property string localIP: "—"
    property int uptime: 0
    property real loadAvg1: 0
    property real loadAvg5: 0
    property real loadAvg15: 0
    property int processCount: 0
    property string kernelVersion: ""
    property var cpuHistory: []
    property var memHistory: []
    property var netHistory: []
    property var gpuHistory: []

    // Visibility settings
    property bool showCpu: true
    property bool showMemory: true
    property bool showNetwork: true
    property bool showDisk: true
    property bool showGpu: true
    property bool showTemperature: true

    // Colors
    property color cpuColor: "#5B8DEF"
    property color memColor: "#FF7359"
    property color gpuColor: "#F25990"
    property color netColor: "#40E68D"
    property color netUpColor: "#B266FF"
    property color diskColor: "#F2A60F"
    property color tempColor: "#FF9933"
    property color warningColor: "#FFBF33"
    property color dangerColor: "#FF5959"

    implicitWidth: 380
    implicitHeight: contentColumn.implicitHeight + 32

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        radius: 12
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                PlasmaComponents.Label {
                    text: "DodoPulse"
                    font.pixelSize: 16
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }
                
                Item { Layout.fillWidth: true }
                
                PlasmaComponents.Label {
                    text: "↑ " + formatUptime(uptime)
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: Kirigami.Theme.disabledTextColor
                }
            }

            // CPU Card
            MetricCard {
                Layout.fillWidth: true
                visible: showCpu
                
                title: "CPU"
                value: cpuUsage.toFixed(1) + "%"
                subtitle: cpuModel
                detail: cpuCores + " cores"
                accentColor: cpuUsage > 90 ? dangerColor : (cpuUsage > 70 ? warningColor : cpuColor)
                history: cpuHistory
                
                temperatureVisible: showTemperature && cpuTemp > 0
                temperature: cpuTemp
                tempColor: cpuTemp > 85 ? dangerColor : (cpuTemp > 70 ? warningColor : tempColor)
            }

            // Memory Card
            MetricCard {
                Layout.fillWidth: true
                visible: showMemory
                
                title: i18n("Memory")
                value: memUsage.toFixed(1) + "%"
                subtitle: memUsedGB.toFixed(1) + " / " + memTotalGB.toFixed(0) + " GB"
                detail: ""
                accentColor: memUsage > 90 ? dangerColor : (memUsage > 75 ? warningColor : memColor)
                history: memHistory
            }

            // GPU Card
            MetricCard {
                Layout.fillWidth: true
                visible: showGpu
                
                title: "GPU"
                value: gpuUsage.toFixed(0) + "%"
                subtitle: gpuModel
                detail: ""
                accentColor: gpuColor
                history: gpuHistory
                
                temperatureVisible: showTemperature && gpuTemp > 0
                temperature: gpuTemp
                tempColor: gpuTemp > 85 ? dangerColor : (gpuTemp > 70 ? warningColor : tempColor)
            }

            // Network Card
            NetworkCard {
                Layout.fillWidth: true
                visible: showNetwork
                
                downloadSpeed: netIn
                uploadSpeed: netOut
                localIP: fullRoot.localIP
                downloadColor: netColor
                uploadColor: netUpColor
                history: netHistory
            }

            // Disk Card
            DiskCard {
                Layout.fillWidth: true
                visible: showDisk
                
                usage: diskUsage
                freeGB: diskFreeGB
                totalGB: diskTotalGB
                accentColor: diskUsage > 90 ? dangerColor : (diskUsage > 75 ? warningColor : diskColor)
            }

            // System Card
            SystemCard {
                Layout.fillWidth: true
                
                loadAvg1: fullRoot.loadAvg1
                loadAvg5: fullRoot.loadAvg5
                loadAvg15: fullRoot.loadAvg15
                processCount: fullRoot.processCount
                kernelVersion: fullRoot.kernelVersion
            }
        }
    }

    function formatUptime(seconds) {
        var d = Math.floor(seconds / 86400)
        var h = Math.floor((seconds % 86400) / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        
        if (d > 0) return d + "d " + h + "h " + m + "m"
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }
}
