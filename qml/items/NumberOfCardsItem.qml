import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property int number

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.margins: parent.width / 20
    height: parent.height / 3
    width: height

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.rgba(Theme.highlightDimmerColor, 0.60)
        //border.color: Theme.highlightBackgroundOpacity
        border.width: 4
    }

    Label {
        anchors.fill: parent
        font.pixelSize: Theme.fontSizeSmall
        text: number
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
