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

    function dbAddDeck(deckName) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('INSERT INTO Decks (Name) VALUES(?)', [ deckName ]);
                    })

    }

    function dbEditDeck(deckId, deckName) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('UPDATE Decks
                                       SET Name = ?
                                       WHERE DeckID = ?', [ deckName, deckId ]);
                    })

    }

    function dbRemoveDeck(deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1.1", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DELETE
                                       FROM Decks
                                       WHERE DeckID = ?', [ deckId ]);
                    })

    }

    function dbReadAllDecks(model) {
        model.clear()
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1.1", "", 1000000);
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT Decks.DeckID, Decks.name, COUNT(Decks_Cards.CardID) AS allCards
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
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.1.1", "", 1000000);
        db.transaction(function (tx) {
            for (var i = 0; i < model.count; i++) {
                var results = tx.executeSql(
                            'SELECT COUNT(Decks_Cards.CardID) AS count
                         FROM Decks_Cards
                         LEFT JOIN Decks ON Decks.DeckId = Decks_Cards.DeckId
                         WHERE Decks.DeckID = ? AND CardId = ?
                         GROUP BY Decks_Cards.DeckId', [model.get(i).id, cardId]);

                if (results.rows.length) {
                    model.set(i, {card: results.rows.item(0).count});
                }
            }
        })
    }
}
