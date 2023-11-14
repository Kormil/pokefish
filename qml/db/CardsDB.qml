import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import CardListModel 1.0

Item {
    Component.onCompleted: {
        //dbRemoveDataBase()
    }

    function dbGetCardsByDeckId(deckId, model) {
        //model.clear()
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
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
                                            small_image_url: results.rows.item(i).Image,
                                            national_number: results.rows.item(i).NationalNumber,
                                            counter: results.rows.item(i).counter
                                        }
                            )
                        }
                    })
    }

    function dbRemoveDataBase() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DROP TABLE Cards');
                        tx.executeSql('DROP TABLE Decks_Cards');
                    })
    }

    function dbAddCardToDeck(card, deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        var cardId = dbSaveCard(tx, card)
                        dbConnectCardAndDeck(tx, cardId, deckId, 1)
                    })
    }

    function dbAddCardListToDeck(cardList, deckId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        var size = cardList.rowCount()
                        for (var i = 0; i < size; i++) {
                            var index = cardList.index(i, 0)

                            var card = {
                                id: cardList.data(index, CardListModel.IdRole),
                                name: cardList.data(index, CardListModel.NameRole),
                                type: cardList.data(index, CardListModel.TypesRole),
                                supertype: cardList.data(index, CardListModel.SuperTypeRole),
                                subtype: cardList.data(index, CardListModel.SubTypeRole),
                                set: cardList.data(index, CardListModel.SetRole),
                                rarity: cardList.data(index, CardListModel.RarityRole),
                                smallImageUrl: cardList.data(index, CardListModel.SmallImageRole),
                                nationalPokedexNumber: cardList.data(index, CardListModel.NationalPokedexNumberRole),
                                counter: cardList.data(index, CardListModel.Counter)
                            }

                            var cardId = dbSaveCard(tx, card)
                            dbConnectCardAndDeck(tx, cardId, deckId, card.counter)
                        }
                    })
    }

    function dbSaveCard(tx, card) {
        var results = tx.executeSql('SELECT CardID
                                    FROM Cards
                                    WHERE ApiCardId = ?', [card.id])
        var cardId
        if (results.rows.length === 0) {
            tx.executeSql('INSERT INTO Cards (ApiCardId, Name, Type, Supertype, Subtype, CardSet, Rarity, Image, NationalNumber) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
                          [
                           card.id,
                           card.name,
                           card.type,
                           card.supertype,
                           card.subtype,
                           card.set,
                           card.rarity,
                           card.smallImageUrl,
                           card.nationalPokedexNumber
                          ])
            cardId = tx.executeSql('SELECT last_insert_rowid() AS id').rows.item(0).id
        } else {
            cardId = results.rows.item(0).CardID
        }

        return cardId
    }

    function dbConnectCardAndDeck(tx, cardId, deckId, cardNumber) {
        var counter = tx.executeSql('SELECT Counter
                                    FROM Decks_Cards
                                    WHERE DeckID = ? AND CardID = ?', [ deckId, cardId ])

        if (counter.rows.length === 0) {
            // It never was the card id in this deck
            tx.executeSql('INSERT INTO Decks_Cards (DeckID, CardID, Counter) VALUES(?, ?, ?)', [ deckId, cardId, cardNumber ])
        } else {
            tx.executeSql('UPDATE Decks_Cards
                           SET counter = counter + ?
                           WHERE DeckID = ? AND CardID = ?', [ cardNumber, deckId, cardId ]);
        }
    }

    function dbUpdateCard(card, apiCardId) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        var results = tx.executeSql('UPDATE Cards
                                                     SET Name = ?, Type = ?, Supertype = ?, Subtype = ?, CardSet = ?, Rarity = ?, Image = ?, NationalNumber = ?
                                                     WHERE ApiCardId = ? ',
                                          [
                                           card.name,
                                           card.type,
                                           card.supertype,
                                           card.subtype,
                                           card.set,
                                           card.rarity,
                                           card.smallImageUrl,
                                           card.nationalPokedexNumber,
                                           apiCardId
                                          ])
                    }
                    )

    }

    function dbGetCardIdByCardApiId(apiCardId, cardID) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
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
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('UPDATE Decks_Cards
                                       SET counter = counter - 1
                                       WHERE DeckID = ? AND CardID = ?', [ deckId, cardId ]);
                    })

    }
}
