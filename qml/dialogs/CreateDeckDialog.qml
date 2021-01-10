import QtQuick 2.0
import Sailfish.Silica 1.0

import "../db"

Dialog {
    id: page

    DecksDB {
        id: decksdb
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        Column {
            width: parent.width

            DialogHeader { }

            TextField {
                id: nameField
                width: parent.width
                placeholderText: qsTr("Name")
                label: qsTr("Name")
            }
        }

    }

    onDone: {
        if (result == DialogResult.Accepted) {
            decksdb.dbAddDeck(nameField.text)
        }
    }

}
