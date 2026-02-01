import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: cardRoot

    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property string localIP: "—"
    property color downloadColor: "#40E68D"
    property color uploadColor: "#B266FF"
    property var history: []

    implicitHeight: 100
    radius: 12
    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.5
            spacing: 4

            PlasmaComponents.Label {
                text: i18n("Network")
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Kirigami.Theme.disabledTextColor
            }

            Item { Layout.preferredHeight: 4 }

            // Download
            RowLayout {
                spacing: 8

                PlasmaComponents.Label {
                    text: "↓"
                    font.pixelSize: 18
                    font.bold: true
                    color: downloadColor
                }

                PlasmaComponents.Label {
                    text: formatSpeed(downloadSpeed)
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "monospace"
                    color: downloadColor
                }
            }

            // Upload
            RowLayout {
                spacing: 8

                PlasmaComponents.Label {
                    text: "↑"
                    font.pixelSize: 18
                    font.bold: true
                    color: uploadColor
                }

                PlasmaComponents.Label {
                    text: formatSpeed(uploadSpeed)
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "monospace"
                    color: uploadColor
                }
            }

            Item { Layout.fillHeight: true }

            // Local IP
            PlasmaComponents.Label {
                text: i18n("Local: ") + localIP
                font.pixelSize: 10
                color: Kirigami.Theme.disabledTextColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Sparkline graph
        SparklineGraph {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 4
            
            values: history
            color: downloadColor
        }
    }

    function formatSpeed(bps) {
        if (bps < 1024) return bps.toFixed(0) + " B/s"
        if (bps < 1024 * 1024) return (bps / 1024).toFixed(1) + " KB/s"
        return (bps / (1024 * 1024)).toFixed(2) + " MB/s"
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
