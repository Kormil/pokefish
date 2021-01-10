import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0

import "../items"

Page {
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listView

            model: searchedCardListModel
            currentIndex: -1
            anchors.fill: parent
            spacing: Theme.paddingMedium

            header: PageHeader {
                id: title
                title: qsTr("Results")
            }

            delegate: ListItem {
                contentHeight: smallCardItem.height
                SmallCardItem {
                    id: smallCardItem
                    card: model
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("CardInfoPage.qml"), {card: searchedCardListModel.card(model.card_id)})
                }
            }

            VerticalScrollDecorator {}
        }
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
        target: Controller
        onSearchStarted: {
            loading.enabled = true
            loading.visible = true
            loading.running = true
        }
    }

    Connections {
        target: Controller
        onSearchCompleted: {
            loading.enabled = false
            loading.visible = false
            loading.running = false

            console.log(listView.count)
            if (listView.count === 0) {
                hintLabel.visible = true
            }
        }
    }

    InteractionHintLabel {
        id: hintLabel
        visible: false
        anchors.bottom: parent.bottom
        Behavior on opacity { FadeAnimation {} }
        text: qsTr("No results")
        anchors.fill: parent
    }
}
