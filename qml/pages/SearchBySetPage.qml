import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0

import "../items"

Page {
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        if (setListModel.empty()) {
            Controller.searchAllSets()
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listView

            model: setListModel
            anchors.fill: parent
            spacing: Theme.paddingMedium

            header: PageHeader {
                id: title
                title: qsTr("Series")
            }

            delegate: ListItem {
                contentHeight: setImage.height

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.10) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Image {
                    id: setImage
                    source: model.image
                    height: Theme.itemSizeHuge
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    cache: true
                }

                onClicked: {
                    Controller.resetSearchResult();
                    pageStack.push(Qt.resolvedUrl("SearchedCardsPage.qml"))
                    Controller.searchCardsBySet(model.set_id)
                }
            }

            VerticalScrollDecorator {}
        }

    }
}
