import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: cardRoot

    property real loadAvg1: 0
    property real loadAvg5: 0
    property real loadAvg15: 0
    property int processCount: 0
    property string kernelVersion: ""

    readonly property color systemColor: "#9980E6"

    implicitHeight: 72
    radius: 12
    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        PlasmaComponents.Label {
            text: i18n("System")
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: Kirigami.Theme.disabledTextColor
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            PlasmaComponents.Label {
                text: i18n("Load:") + " " + loadAvg1.toFixed(2) + "  " + loadAvg5.toFixed(2) + "  " + loadAvg15.toFixed(2)
                font.pixelSize: 12
                font.family: "monospace"
                font.weight: Font.Medium
                color: systemColor
            }

            Item { Layout.fillWidth: true }

            PlasmaComponents.Label {
                text: i18n("Processes:") + " " + processCount
                font.pixelSize: 12
                font.family: "monospace"
                font.weight: Font.Medium
                color: Kirigami.Theme.disabledTextColor
            }
        }

        PlasmaComponents.Label {
            text: i18n("Kernel:") + " " + kernelVersion
            font.pixelSize: 11
            font.family: "monospace"
            color: Qt.darker(Kirigami.Theme.disabledTextColor, 1.2)
        }
    }

    // Hover effect
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: cardRoot.color = Qt.lighter(Qt.darker(Kirigami.Theme.backgroundColor, 1.05), 1.1)
        onExited: cardRoot.color = Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
    }
}
