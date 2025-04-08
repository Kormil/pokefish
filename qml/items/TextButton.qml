import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

BackgroundItem {
    property string text
    property string image
    property string colorize: "transparent"
    id: master

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: master.image

        width: parent.width > sourceSize.width ? sourceSize.width : parent.width
        height: parent.height > sourceSize.height ? sourceSize.height : parent.height

        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: icon
        source: icon
        color: colorize
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
