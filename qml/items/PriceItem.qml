import QtQuick 2.0
import Sailfish.Silica 1.0
import MarketPrice 1.0

Row {
    id: item
    property string market_name
    property string price_name
    property var price_type
    property int visibleSize: 0

    height: Theme.itemSizeSmall
    visible: low_label.text.length > 0

    onVisibleChanged: {
        if (visible === true) {
            item.visibleSize = height
        }

        if (visible === false) {
            item.visibleSize = 0
        }
    }

    Column {
        width: parent.width / 3
        height: Theme.itemSizeSmall
        Label {
            id: typeLabel
            text: price_name
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            width: parent.width
        }
    }

    Column {
        width: parent.width / 9 * 2
        height: Theme.itemSizeSmall
        Label {
            id: low_label
            text: marketPricePage.card.prices(market_name, price_type, PriceLevel.Low)
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            width: parent.width
        }
    }
    Column {
        width: parent.width / 9 * 2
        height: Theme.itemSizeSmall
        Label {
            text: marketPricePage.card.prices(market_name, price_type, PriceLevel.Market)
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            width: parent.width
            font.bold: true
        }
    }
    Column {
        width: parent.width / 9 * 2
        height: Theme.itemSizeSmall
        Label {
            text: marketPricePage.card.prices(market_name, price_type, PriceLevel.High)
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            width: parent.width
        }
    }
}
