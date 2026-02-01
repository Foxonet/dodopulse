import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

MouseArea {
    id: compactRoot

    property real cpuUsage: 0
    property real memUsage: 0
    property color cpuColor: "#5B8DEF"
    property color memColor: "#FF7359"

    Layout.minimumWidth: row.implicitWidth
    Layout.minimumHeight: Kirigami.Units.iconSizes.medium

    hoverEnabled: true

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        // CPU mini bar
        Rectangle {
            Layout.preferredWidth: 4
            Layout.preferredHeight: parent.height - 4
            Layout.alignment: Qt.AlignVCenter
            color: Qt.darker(cpuColor, 2)
            radius: 2

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * (cpuUsage / 100)
                color: cpuUsage > 90 ? "#FF5959" : (cpuUsage > 70 ? "#FFBF33" : cpuColor)
                radius: 2

                Behavior on height {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                }
            }
        }

        // CPU percentage text
        PlasmaComponents.Label {
            text: Math.round(cpuUsage) + "%"
            font.pixelSize: Kirigami.Units.fontSizes.small
            font.family: "monospace"
            color: cpuUsage > 90 ? "#FF5959" : (cpuUsage > 70 ? "#FFBF33" : Kirigami.Theme.textColor)
        }

        // Memory mini bar
        Rectangle {
            Layout.preferredWidth: 4
            Layout.preferredHeight: parent.height - 4
            Layout.alignment: Qt.AlignVCenter
            color: Qt.darker(memColor, 2)
            radius: 2

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * (memUsage / 100)
                color: memUsage > 90 ? "#FF5959" : (memUsage > 75 ? "#FFBF33" : memColor)
                radius: 2

                Behavior on height {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                }
            }
        }

        // Memory percentage text
        PlasmaComponents.Label {
            text: Math.round(memUsage) + "%"
            font.pixelSize: Kirigami.Units.fontSizes.small
            font.family: "monospace"
            color: memUsage > 90 ? "#FF5959" : (memUsage > 75 ? "#FFBF33" : Kirigami.Theme.textColor)
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: "DodoPulse"
        subText: "CPU: " + Math.round(cpuUsage) + "% | Memory: " + Math.round(memUsage) + "%"
    }
}
