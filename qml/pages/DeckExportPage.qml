import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import DeckExporter 1.0
import CardListModel 1.0

import "../items"
import "../dialogs"

Page {
    id: page
    property string deckName: ""
    property DeckExporter deckExporter

    allowedOrientations: Orientation.All

    SaveFileDialog {
        id: saveFileDialog
        name: deckName
        selectedPath: StandardPaths.documents
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Save as file")
                onClicked: {
                    pageStack.push(saveFileDialog, {
                                   fileContent: deckExporter.text()
                                   })
                }
            }

            MenuItem {
                text: qsTr("Copy")
                onClicked: {
                    Clipboard.text = exportedCardsText.text
                }
            }
        }

        Column {
            id: column
            width: parent.width - 2 * Theme.paddingMedium
            x: Theme.paddingMedium

            PageHeader {
                title: deckName
            }

            Text {
                id: exportedCardsText
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.Wrap
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        id: loading
        anchors.centerIn: parent
        running: true
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    Connections {
        target: deckExporter
        onExportStarted: {
            loading.enabled = true
            loading.visible = true
            loading.running = true
        }
    }

    Connections {
        target: deckExporter
        onExportFinished: {
            loading.enabled = false
            loading.visible = false
            loading.running = false

            exportedCardsText.text = deckExporter.text()
        }
    }
}
