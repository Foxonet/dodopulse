import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_showCpu: showCpuCheckBox.checked
    property alias cfg_showMemory: showMemoryCheckBox.checked
    property alias cfg_showNetwork: showNetworkCheckBox.checked
    property alias cfg_showDisk: showDiskCheckBox.checked
    property alias cfg_showGpu: showGpuCheckBox.checked
    property alias cfg_showTemperature: showTemperatureCheckBox.checked
    property alias cfg_compactMode: compactModeCheckBox.checked

    SpinBox {
        id: updateIntervalSpinBox
        Kirigami.FormData.label: i18n("Update interval (ms):")
        from: 500
        to: 10000
        stepSize: 100
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Visible Sections")
    }

    CheckBox {
        id: showCpuCheckBox
        Kirigami.FormData.label: i18n("CPU:")
    }

    CheckBox {
        id: showMemoryCheckBox
        Kirigami.FormData.label: i18n("Memory:")
    }

    CheckBox {
        id: showNetworkCheckBox
        Kirigami.FormData.label: i18n("Network:")
    }

    CheckBox {
        id: showDiskCheckBox
        Kirigami.FormData.label: i18n("Disk:")
    }

    CheckBox {
        id: showGpuCheckBox
        Kirigami.FormData.label: i18n("GPU:")
    }

    CheckBox {
        id: showTemperatureCheckBox
        Kirigami.FormData.label: i18n("Temperature:")
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Display")
    }

    CheckBox {
        id: compactModeCheckBox
        Kirigami.FormData.label: i18n("Compact mode:")
    }
}
