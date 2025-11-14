import QtQuick 2.0
import QtQml.Models 2.2
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0
import Settings 1.0

import ".."
import "../../items"
import "../../dialogs"
import "../../db"

Page {
    property string cardId
    property var parentPage: undefined
    property int current_index
    property int delegateHeight: page.height - bottombar.height - Theme.paddingMedium

    anchors.bottomMargin: Theme.horizontalPageMargin

    onCurrent_indexChanged: {
        cardInfoPage.current_index = current_index
    }

    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"

    id: page

    allowedOrientations: Orientation.All

    onStatusChanged: {
        if (page.status === PageStatus.Active) {
            page.navigationStyle = PageNavigation.Vertical
        }  else if (page.status === PageStatus.Inactive) {
            page.navigationStyle = PageNavigation.Horizontal
        }
    }

    Component.onCompleted: {
        pages_wiew.model = pageModel
        pages_wiew.currentIndex = 1
    }

    ObjectModel {
        id: pageModel

        MarketPricePage {
            id: marketPricePage
            card_id: page.cardId

            width: page.width
            height: delegateHeight
        }
        CardInfoPage {
            id: cardInfoPage
            card_id: page.cardId

            width: page.width
            height: delegateHeight
        }
        SelectDeckPage {
            id: selectDeckPage
            width: page.width
            height: delegateHeight
        }
    }

    SilicaFlickable {
        id: mainColumnFlickable
        width: page.width
        height: page.height

        SilicaListView {
            id: pages_wiew

            visible: false

            anchors.fill: parent

            snapMode: ListView.SnapOneItem
            orientation: ListView.HorizontalFlick
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true

            onCurrentItemChanged: {
                selectDeckPage.refresh(cardInfoPage.card)
                marketPricePage.refresh(cardInfoPage.card)
            }
        }

        VerticalScrollDecorator {
            flickable: pages_wiew
        }
    }

    Binding {
        target: page
        property: "current_index"
        value: cardInfoPage.current_index
    }

    GlassItem {
        id: effect
        height: Theme.paddingMedium
        width: page.width
        color: Theme.secondaryColor
        cache: false
        anchors.bottom: bottombar.top
    }

    Row {
        id: bottombar
        anchors.bottom: page.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: Theme.paddingLarge
        height: Theme.buttonWidthSmall / 3 + Theme.horizontalPageMargin

        TextButton {
            height: bottombar.height
            width: page.width / 6
            image: "qrc:///graphics/icons/" + colorScheme + "/stock.png"
            colorize: pages_wiew.currentIndex === 0 ? Theme.highlightColor : "transparent"

            onClicked: {
                pages_wiew.currentIndex = 0
            }
        }

        TextButton {
            height: bottombar.height
            width: page.width / 6
            image: "qrc:///graphics/icons/" + colorScheme + "/card2.png"
            colorize: pages_wiew.currentIndex === 1 ? Theme.highlightColor : "transparent"

            onClicked: {
                pages_wiew.currentIndex = 1
            }
        }

        TextButton {
            height: bottombar.height
            width: page.width / 6
            image: "qrc:///graphics/icons/" + colorScheme + "/deck.png"
            colorize: pages_wiew.currentIndex === 2 ? Theme.highlightColor : "transparent"

            onClicked: {
                pages_wiew.currentIndex = 2
            }
        }
    }

    BusyIndicator {
        id: loading
        anchors.centerIn: parent
        running: true
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        visible: true
    }

    Timer {
        interval: pages_wiew.highlightMoveDuration
        running: true
        repeat: false

        onTriggered: {
            loading.visible = false
            loading.running = false

            pages_wiew.visible = true
        }
    }

}
