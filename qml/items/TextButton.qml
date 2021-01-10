import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property string text
    property string image
    id: master

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: master.image
    }

    Label {
        id: textLabel
        anchors.top: icon.bottom
        text: master.text
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: pressed
               ? Theme.highlightColor
               : Theme.primaryColor
    }
}
