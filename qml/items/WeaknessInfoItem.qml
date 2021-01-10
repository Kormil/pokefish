import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    property string name
    property string type
    property string value

    id: weakColumn

    height: nameLabel.height * 2
    spacing: Theme.paddingSmall

    Label {
        id: nameLabel
        text: name
        font.pixelSize: Theme.fontSizeSmall
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
        height: nameLabel.height
        width: weaknessIcon.width + weaknessValue.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingMedium

        Image {
            id: weaknessIcon
            fillMode: Image.PreserveAspectFit
            height: nameLabel.height
            source: "qrc:///graphics/types/"+type+".png"
            smooth: false
            cache: true
        }

        Label {
            id: weaknessValue
            text: value
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
