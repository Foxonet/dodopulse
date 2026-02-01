import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: cardRoot

    property real usage: 0
    property real freeGB: 0
    property real totalGB: 0
    property color accentColor: "#F2A60F"

    implicitHeight: 80
    radius: 12
    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2

                PlasmaComponents.Label {
                    text: usage.toFixed(0) + "%"
                    font.pixelSize: 22
                    font.bold: true
                    font.family: "monospace"
                    color: accentColor
                }

                PlasmaComponents.Label {
                    text: i18n("Disk")
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: Kirigami.Theme.disabledTextColor
                }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignRight

                PlasmaComponents.Label {
                    text: freeGB.toFixed(0) + " GB " + i18n("free")
                    font.pixelSize: 11
                    font.family: "monospace"
                    font.weight: Font.Medium
                    color: Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignRight
                }

                PlasmaComponents.Label {
                    text: i18n("of") + " " + totalGB.toFixed(0) + " GB"
                    font.pixelSize: 10
                    color: Qt.darker(Kirigami.Theme.disabledTextColor, 1.2)
                    Layout.alignment: Qt.AlignRight
                }
            }
        }

        // Progress bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            radius: 5
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (usage / 100)
                radius: 5
                color: accentColor

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }
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
