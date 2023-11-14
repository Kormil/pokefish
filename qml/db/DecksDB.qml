import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    Component.onCompleted: {
        //dbRemoveDataBase()
    }

    function dbRemoveDataBase() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DROP TABLE Decks');
                    })
    }

    function dbAddDeck(deckName, deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        var result = tx.executeSql('INSERT INTO Decks (Name) VALUES(?)', [ deckName ]);
                        deckId.key = result.insertId
                    })

    }

    function dbEditDeck(deckId, deckName) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('UPDATE Decks
                                       SET Name = ?
                                       WHERE DeckID = ?', [ deckName, deckId ]);
                    })

    }

    function dbRemoveDeck(deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DELETE
                                       FROM Decks
                                       WHERE DeckID = ?', [ deckId ]);
                    })

    }

    function dbReadAllDecks(model) {
        model.clear()
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT Decks.DeckID, Decks.name, SUM(Decks_Cards.Counter) AS allCards
                         FROM Decks
                         LEFT JOIN Decks_Cards ON Decks.DeckId = Decks_Cards.DeckId
                         GROUP BY Decks.name')

            for (var i = 0; i < results.rows.length; i++) {
                model.append({
                                 id: results.rows.item(i).DeckID,
                                 name: results.rows.item(i).Name,
                                 card: 0,
                                 cards: results.rows.item(i).allCards
                             })
            }
        })
    }

    function dbNumberOfCards(model, cardId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(function (tx) {
            for (var i = 0; i < model.count; i++) {
                var results = tx.executeSql(
                            'SELECT counter
                         FROM Decks_Cards
                         WHERE DeckId = ? AND CardId = ?', [model.get(i).id, cardId]);

                if (results.rows.length) {
                    model.set(i, {card: results.rows.item(0).counter});
                }
            }
        })
    }

    function dbNumberOfCardsByCardApiId(deckId, cardId, ret_counter) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);

        db.transaction(function (tx) {
                var results = tx.executeSql(
                            'SELECT counter
                         FROM Decks_Cards
                         LEFT JOIN Cards ON Cards.CardID = Decks_Cards.CardId
                         WHERE DeckId = ? AND Cards.ApiCardId = ?', [deckId, cardId]);

                if (results.rows.length) {
                    ret_counter.key = results.rows.item(0).counter;
                }
            }
        )
    }
}
