import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0
import Settings 1.0

import "../items"
import "cards"

Page {
    id: page
    property string title: "Result"

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listView

            model: CardListProxyModel {
                id: cardListProxyModel
                cardListModel: searchedCardListModel
                sorting: Settings.sortCards
                sortBy: Settings.sortCardsBy
            }

            anchors.fill: parent
            spacing: Theme.paddingMedium
            highlightFollowsCurrentItem: true

            header: PageHeader {
                id: title
                title: page.title
            }

            delegate: ListItem {
                property int indexOfThisDelegate: index

                contentHeight: smallCardItem.height

                SmallCardItem {
                    id: smallCardItem
                    card: model
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("cards/CardInfoMainPage.qml"), {
                                       current_index: indexOfThisDelegate
                                   })
                }
            }

            VerticalScrollDecorator {}
        }
    }

    Binding {
        target: listView
        property: "currentIndex"
        value: pageStack.currentPage.current_index
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
