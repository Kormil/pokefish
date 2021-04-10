import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "", "", 1000000, function(db) {
            dbCreateCardsTable(db)
            dbCreateDecksTable(db)
            dbCreateSearchedTable(db)
            db.changeVersion("", "1.1.1");

        });

        dbMigrateToNewestVersion();
    }

    function dbCreateCardsTable(db) {
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Cards(
                                        CardID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                        ApiCardId TEXT NOT NULL,
                                        Name TEXT NOT NULL,
                                        Type TEXT,
                                        Supertype TEXT,
                                        Subtype TEXT,
                                        CardSet TEXT,
                                        Rarity TEXT,
                                        Image TEXT,
                                        NationalNumber INTEGER)');
                    })

        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Decks_Cards(
                                        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                        DeckID INTEGER NOT NULL,
                                        CardID INTEGER NOT NULL)');
                    })
    }

    function dbCreateDecksTable(db) {
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Decks(
                                        DeckID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                        Name TEXT NOT NULL)');
                    })
    }

    function dbCreateSearchedTable(db) {
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Searched(
                                        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                        Name TEXT NOT NULL,
                                        Type TEXT,
                                        Subtype TEXT)');
                    })
    }

    function dbMigrateToNewestVersion() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "", "", 1000000);
        if (db.version === "1.1.1") {
            console.log("PokefishDB version: 1.1.1")
            return;
        }

        if (db.version === "1.0") {
            console.log("1.0")
            db.changeVersion("1.0", "1.1", function(tx) {
                tx.executeSql("ALTER TABLE Searched ADD COLUMN Type TEXT");
                tx.executeSql("ALTER TABLE Searched ADD COLUMN Subtype TEXT");
            }
        )}

        db = LocalStorage.openDatabaseSync("PokefishDB", "", "", 1000000);
        if (db.version === "1.1") {
            console.log("1.1")
            db.changeVersion("1.1", "1.1.1", function(tx) {
                tx.executeSql("ALTER TABLE Cards ADD COLUMN NationalNumber INTEGER");
            }
        )}

        db = LocalStorage.openDatabaseSync("PokefishDB", "", "", 1000000);
        if (db.version === "1.1.1") {
            console.log("1.1.1")
        }
    }
}


