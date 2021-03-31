import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: abilityInfo
    property string text

    width: parent.width
    height: column.height

    Column {
        id: column
        width: parent.width

        Text {
            id: textLabel
            width: parent.width
            text: abilityInfo.text
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
        }
    }
}
