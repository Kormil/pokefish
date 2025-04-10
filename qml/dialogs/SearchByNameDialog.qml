import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0

import "../items"
import "../pages"
import "../db"


Dialog {
    id: searchByNameDialog

    property bool showAdvance: false
    property int advanceSearchingHeight

    SearchParameters {
        id: search_parameters
    }

    SearchedDB {
        id: searcheddb
    }

    function setParameters(name, type, subtype) {
        searchField.text = name
        typeComboBox.currentIndex = 0
        subtypeComboBox.currentIndex = 0

        var row
        for (row = 0; row < typesListModel.rowCount(); ++row) {
          if (typesListModel.data(typesListModel.index(row, 0)) === type) {
              typeComboBox.currentIndex = row
              break
          }
        }

        for (row = 0; row < subtypesListModel.rowCount(); ++row) {
          if (subtypesListModel.data(subtypesListModel.index(row, 0)) === subtype) {
              subtypeComboBox.currentIndex = row
              break
          }
        }
    }

    allowedOrientations: Orientation.All
    acceptDestination: Qt.resolvedUrl("../pages/SearchedCardsPage.qml")
    acceptDestinationAction: PageStackAction.Push

    Component.onCompleted: {
        Controller.resetSearchResult();
        searchedList.clear()
        searcheddb.dbReadAll(searchedList)
    }

    onAccepted: {
        search_parameters.name = searchField.text
        search_parameters.type = typeComboBox.value
        search_parameters.subtype = subtypeComboBox.value

        searcheddb.dbAdd(search_parameters)
        searcheddb.dbClean(50)

        searchedList.clear()
        searcheddb.dbReadAll(searchedList)

        Controller.resetSearchResult();
        Controller.searchCardsByName(search_parameters)
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Show advance")
                onClicked: {
                    if (searchByNameDialog.showAdvance) {
                        searchByNameDialog.advanceSearchingHeight = 0;
                        text = qsTr("Show advance")
                    } else {
                        searchByNameDialog.advanceSearchingHeight = typeComboBox.height + subtypeComboBox.height + effect.height
                        text = qsTr("Hide advance")
                    }

                    animation.running = true
                }
            }
        }

        Column {
            anchors.fill: parent
            DialogHeader {
                id: header
            }

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Name")

                Binding {
                    value: searchField.text.toLowerCase().trim()
                }
            }

            Item {
                id: advanceSearchingColumn
                height: 0
                width: parent.width
                visible: searchByNameDialog.showAdvance


                    ComboBox {
                        id: typeComboBox
                        label: "Type"
                        height: Theme.itemSizeSmall
                        menu: ContextMenu {
                            Repeater {
                                model: typesListModel
                                MenuItem { text: model.display }
                            }
                        }
                    }

                    ComboBox {
                        id: subtypeComboBox
                        label: "Subtype"
                        height: Theme.itemSizeSmall
                        menu: ContextMenu {
                            Repeater {
                                model: subtypesListModel
                                MenuItem { text: model.display }
                            }
                        }

                        anchors.top: typeComboBox.bottom
                    }

                    GlassItem {
                        id: effect
                        height: Theme.paddingMedium
                        width: searchByNameDialog.width
                        color: Theme.secondaryColor
                        cache: false
                        visible: true
                        anchors.bottom: advanceSearchingColumn.bottom
                    }

            }

            ListModel {
                id: searchedList
            }

            SilicaListView {
                id: listView

                model: searchedList
                width: parent.width
                height: searchByNameDialog.height - advanceSearchingColumn.height - searchField.height - header.height

                delegate: BackgroundItem {
                    id: delegate

                    Row {
                        x: Theme.horizontalPageMargin
                        width: parent.width - Theme.horizontalPageMargin
                        spacing: Theme.paddingSmall
                        height: Theme.itemSizeSmall

                        Label {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: model.name
                        }

                        Label {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: model.type !== "Any" ? model.type : ""
                            color: Theme.secondaryColor
                        }

                        Label {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: model.subtype !== "Any" ? model.subtype : ""
                            color: Theme.secondaryColor
                        }
                    }

                    IconButton {
                        anchors.right: parent.right
                        icon.source: "image://theme/icon-m-setting"
                        anchors.rightMargin: Theme.horizontalPageMargin / 2

                        onClicked: {
                            setParameters(model.name, model.type, model.subtype)
                        }
                    }

                    onClicked: {
                        setParameters(model.name, model.type, model.subtype)
                        accept()
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }

    PropertyAnimation {
        id: animation
        target: advanceSearchingColumn
        property: "height"
        to: searchByNameDialog.advanceSearchingHeight
        duration: 250
        easing.type: Easing.InQuad

        onStarted: {
            searchByNameDialog.showAdvance = !searchByNameDialog.showAdvance
            typeComboBox.visible = false
            subtypeComboBox.visible = false
        }

        onStopped: {
            typeComboBox.visible = searchByNameDialog.showAdvance
            subtypeComboBox.visible = searchByNameDialog.showAdvance
        }
    }
}
