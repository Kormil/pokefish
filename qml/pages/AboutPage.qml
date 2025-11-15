import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        anchors.bottomMargin: Theme.paddingMedium
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr("About")
            }

            Image {
                id: appIconImage
                anchors.horizontalCenter: parent.horizontalCenter
                height: 172
                source: "qrc:///icons/172x172/harbour-pokefish.png"
            }

            Label {
                id: appNameLabel
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.primaryColor
                text: "Pokefish"
            }

            Label {
                id: appVersionLabel
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("version") + " 1.3.0"
            }

            Label {
                id: appDescriptionLabel
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Application for organize your cards and decks of pokemon TCG.")
            }

            SectionHeader {
                text: qsTr("Copyright")
            }

            Label {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                text: "Bartłomiej Seliga"
            }

            SectionHeader {
                text: qsTr("Special thanks to")
            }

            Label {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                text: "pokemontcg.io - " + qsTr("pokemon tcg data")
            }

            Label {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                text: "icycatelf - " + qsTr("pokemon type icons")
            }

            SectionHeader {
                text: qsTr("Disclaimer")
            }

            Text {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignJustify
                text: qsTr("This app is unoffical and not affiliated with Nintendo or The Pokémon Company. Pokémon and Pokémon character names are trademarks of Nintendo. No copyright infringement intended.")
            }

            GlassItem {
                id: effect
                height: Theme.paddingMedium
                width: page.width
                color: Theme.secondaryColor
                cache: false
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("App license")
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Source code")
                onClicked: Qt.openUrlExternally("https://github.com/Kormil/pokefish")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Buy me a beer")
                onClicked: Qt.openUrlExternally("https://paypal.me/kormil")
            }
        }
    }
}
