import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0

import "../items"
import "../pages"
import "../db"

Dialog {
    id: searchByNameDialog

    SearchedDB {
        id: searcheddb
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations

    allowedOrientations: Orientation.All
    acceptDestination: Qt.resolvedUrl("../pages/SearchedCardsPage.qml")
    acceptDestinationAction: PageStackAction.Push

    Component.onCompleted: {
        searcheddb.dbCreateDataBase()

        Controller.resetSearchResult();
        searchedList.clear()
        searcheddb.dbReadAll(searchedList)
    }

    onAccepted: {
        searcheddb.dbAdd(searchField.text)
        searcheddb.dbClean(50)

        searchedList.clear()
        searcheddb.dbReadAll(searchedList)

        Controller.resetSearchResult();
        Controller.searchCardsByName(searchField.text)
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        Column {
            anchors.fill: parent
            DialogHeader { }

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Name")

                Binding {
                    value: searchField.text.toLowerCase().trim()
                }
            }

            ListModel {
                id: searchedList
            }

            SilicaListView {
                id: listView

                model: searchedList
                width: parent.width
                height: contentHeight

                delegate: BackgroundItem {
                    id: delegate

                    Label {
                        anchors.fill: parent
                        anchors.margins: Theme.horizontalPageMargin
                        text: model.name
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        searchField.text = model.name
                    }
                }
                VerticalScrollDecorator {}
            }
        }
    }
}
