import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: atackInfo
    property string name
    property string text
    property string damage
    property var cost

    width: parent.width
    height: column.height

    Column {
        id: column
        width: parent.width

        Item {
            id: row
            width: parent.width
            height: typeLabel.height


            ListView {
                id: costListView
                width: parent.width - rightColumn.width
                anchors.left: parent.left
                height: typeLabel.height
                orientation: Qt.Horizontal
                spacing: Theme.paddingSmall

                model: cost

                delegate: Image {
                    id: icon
                    height: typeLabel.height - 2 * Theme.paddingSmall
                    sourceSize.height: typeLabel.height
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:///graphics/types/"+model.modelData+".png"
                    smooth: false
                    cache: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                id: rightColumn
                anchors.right: parent.right
                spacing: Theme.paddingMedium

                Label {
                    id: typeLabel
                    text: name
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    id: nameLabel
                    text: damage
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Text {
            id: textLabel
            width: parent.width
            visible: atackInfo.text.length > 0
            text: atackInfo.text
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
        }
    }
}
