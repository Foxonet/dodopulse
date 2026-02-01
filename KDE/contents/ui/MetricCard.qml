import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: cardRoot

    property string title: ""
    property string value: ""
    property string subtitle: ""
    property string detail: ""
    property color accentColor: "#5B8DEF"
    property var history: []
    
    property bool temperatureVisible: false
    property real temperature: 0
    property color tempColor: "#FF9933"

    implicitHeight: 88
    radius: 12
    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
    border.width: 1

    // Glow effect based on usage
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: 14
        color: "transparent"
        border.color: accentColor
        border.width: 2
        opacity: parseFloat(value) > 50 ? (parseFloat(value) - 50) / 100 * 0.5 : 0
        visible: opacity > 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.55
            spacing: 2

            RowLayout {
                spacing: 8

                PlasmaComponents.Label {
                    text: value
                    font.pixelSize: 26
                    font.bold: true
                    font.family: "monospace"
                    color: accentColor
                }

                // Temperature badge
                Rectangle {
                    visible: temperatureVisible
                    Layout.preferredWidth: tempLabel.implicitWidth + 16
                    Layout.preferredHeight: 24
                    radius: 6
                    color: Qt.rgba(tempColor.r, tempColor.g, tempColor.b, 0.15)

                    PlasmaComponents.Label {
                        id: tempLabel
                        anchors.centerIn: parent
                        text: Math.round(temperature) + "°C"
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "monospace"
                        color: tempColor
                    }
                }
            }

            PlasmaComponents.Label {
                text: title
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Kirigami.Theme.disabledTextColor
            }

            Item { Layout.fillHeight: true }

            PlasmaComponents.Label {
                text: subtitle
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Kirigami.Theme.disabledTextColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                visible: detail !== ""
                text: detail
                font.pixelSize: 10
                color: Qt.darker(Kirigami.Theme.disabledTextColor, 1.2)
            }
        }

        // Sparkline graph
        SparklineGraph {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 4
            
            values: history
            color: accentColor
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
