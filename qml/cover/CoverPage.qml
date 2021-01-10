import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        fillMode: Image.PreserveAspectFit
        //width: parent.width / 3 * 2
        //height: parent.height / 2
        source: "qrc:///graphics/icons/cover/cover.png"
        anchors.centerIn: parent
        opacity: 0.2
    }
}
