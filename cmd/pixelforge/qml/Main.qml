import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 1200
    height: 760
    visible: true
    title: "PixelForge Canvas"

    Rectangle {
        anchors.fill: parent
        color: "#f7f9fc"

        Text {
            anchors.centerIn: parent
            text: "PixelForge Canvas MVP shell"
            color: "#20242a"
            font.pixelSize: 28
            font.bold: true
        }
    }
}

