import QtQuick 2.0
import Sailfish.Silica 1.0

import "../db"

Dialog {
    property int deckId
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
                placeholderText: qsTr("New name")
                label: qsTr("Name")
            }
        }

    }

    onDone: {
        if (result == DialogResult.Accepted) {
            decksdb.dbEditDeck(deckId, nameField.text)
        }
    }

}
