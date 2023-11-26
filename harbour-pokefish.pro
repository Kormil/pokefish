# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-pokefish
CONFIG += sailfishapp

SOURCES += \
           src/connection.cpp \
           src/controller.cpp \
           src/deckexporter.cpp \
           src/deckimporter.cpp \
           src/harbour-pokefish.cpp \
           src/model/cardlistmodel.cpp \
           src/model/setlistmodel.cpp \
           src/modelsmanager.cpp \
           src/request.cpp \
           src/settings.cpp \
           src/types/ability.cpp \
           src/types/attack.cpp \
           src/types/card.cpp \
           src/types/deck.cpp \
           src/types/set.cpp \
           src/utils/filesaver.cpp

HEADERS += src/types/card.h \
           src/connection.h \
           src/controller.h \
           src/deckexporter.h \
           src/deckimporter.h \
           src/model/cardlistmodel.h \
           src/model/setlistmodel.h \
           src/modelsmanager.h \
           src/networkaccessmanagerfactory.h \
           src/request.h \
           src/searchparameters.h \
           src/settings.h \
           src/types/ability.h \
           src/types/attack.h \
           src/types/deck.h \
           src/types/set.h \
           src/utils/filesaver.h

DISTFILES += \
    graphics/icons/card.png \
    graphics/icons/deck.png \
    graphics/icons/pokeball.png \
    harbour-pokefish.desktop \
    harbour-pokefish/qml/items/AdditionalTextItem.qml \
    items/NumberOfCardsItem.qml \
    qml/cover/CoverPage.qml \
    qml/db/CardsDB.qml \
    qml/db/DatabaseManager.qml \
    qml/db/DecksDB.qml \
    qml/db/SearchedDB.qml \
    qml/dialogs/CreateDeckDialog.qml \
    qml/dialogs/DeckImportDialog.qml \
    qml/dialogs/EditDeckDialog.qml \
    qml/dialogs/SaveFileDialog.qml \
    qml/dialogs/SearchByNameDialog.qml \
    qml/dialogs/SelectDeckDialog.qml \
    qml/harbour-pokefish.qml \
    qml/items/AbilityInfo.qml \
    qml/items/AtackInfo.qml \
    qml/items/CardSwitcher.qml \
    qml/items/DeckItem.qml \
    qml/items/SmallCardItem.qml \
    qml/items/TextButton.qml \
    qml/items/WeaknessInfoItem.qml \
    qml/pages/AboutPage.qml \
    qml/pages/BigCardPage.qml \
    qml/pages/CardInDeckPage.qml \
    qml/pages/CardInfoPage.qml \
    qml/pages/DeckExportPage.qml \
    qml/pages/DeckListPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/LicensePage.qml \
    qml/pages/SearchBySetPage.qml \
    qml/pages/SearchedCardsPage.qml \
    qml/pages/SettingsPage.qml \
    rpm/harbour-pokefish.changes.in \
    rpm/harbour-pokefish.changes.run.in \
    rpm/harbour-pokefish.spec \
    rpm/harbour-pokefish.yaml \
    translations/*.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-pokefish-de.ts

RESOURCES += \
    graphics.qrc

license.files = LICENSE
license.path = /usr/share/$${TARGET}
INSTALLS += license
