import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    Component.onCompleted: {
        //dbRemoveDataBase()
        dbCreateDataBase()
    }

    function dbCreateDataBase() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "", "", 1000000);
        if (db.version === "1.0") {
            db.changeVersion("1.0", "1.1", function(tx) {
            }
        )}

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
                                        Image TEXT)');
                    })

        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Decks_Cards(
                                        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                        DeckID INTEGER NOT NULL,
                                        CardID INTEGER NOT NULL)');
                    })
    }

    function dbGetCardsByDeckId(deckId, model) {
        //model.clear()
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        var results = tx.executeSql('SELECT *
                                                    FROM Cards
                                                    INNER JOIN Decks_Cards
                                                    ON Cards.CardId = Decks_Cards.CardID
                                                    WHERE Decks_Cards.DeckID = ?', [deckId])
                        for (var i = 0; i < results.rows.length; i++) {
                            model.append( {
                                            card_id: results.rows.item(i).ApiCardId,
                                            name: results.rows.item(i).Name,
                                            types: results.rows.item(i).Type,
                                            super_type: results.rows.item(i).Supertype,
                                            sub_type: results.rows.item(i).Subtype,
                                            set: results.rows.item(i).CardSet,
                                            rarity: results.rows.item(i).Rarity,
                                            small_image_url: results.rows.item(i).Image
                                        }
                            )
                        }
                    })
    }

    function dbRemoveDataBase() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DROP TABLE Cards');
                        tx.executeSql('DROP TABLE Decks_Cards');
                    })
    }

    function dbAddCard(card, deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1", "", 1000000);
        console.info("DeckId: " + deckId)
        console.info("card: " + card)
        db.transaction(
                    function(tx) {
                        var results = tx.executeSql('SELECT CardID
                                                    FROM Cards
                                                    WHERE ApiCardId = ?', [card.id])
                        var cardId
                        if (results.rows.length == 0) {
                            tx.executeSql('INSERT INTO Cards (ApiCardId, Name, Type, Supertype, Subtype, CardSet, Rarity, Image) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
                                          [ card.id, card.name, card.type, card.supertype, card.subtype, card.set, card.rarity, card.smallImageUrl ])
                            cardId = tx.executeSql('SELECT last_insert_rowid() AS id').rows.item(0).id
                        } else {
                            cardId = results.rows.item(0).CardID
                        }

                        tx.executeSql('INSERT INTO Decks_Cards (DeckID, CardID) VALUES(?, ?)', [ deckId, cardId ])
                    }
                    )

    }

    function dbGetCardIdByCardApiId(apiCardId, cardID) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        var results = tx.executeSql('SELECT CardID
                                                    FROM Cards
                                                    WHERE ApiCardId = ?', [apiCardId])
                        if (results.rows.length) {
                            cardID.key = results.rows.item(0).CardID
                        }
                    }
                    )
    }

    function dbRemoveCardFromDeck(cardId, deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DELETE
                                       FROM Decks_Cards
                                       WHERE ID IN (SELECT ID FROM Decks_Cards WHERE DeckID = ? AND CardID = ? ORDER BY ID DESC LIMIT 1)', [ deckId, cardId ]);
                    })

    }
}
