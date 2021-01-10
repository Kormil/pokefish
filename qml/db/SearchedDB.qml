import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    Component.onCompleted: {
        dbCreateDataBase()
    }

    function dbRemoveDataBase() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('DROP TABLE Searched');
                    })
    }

    function dbCreateDataBase() {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Searched(
                                        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                        Name TEXT NOT NULL)');
                    })
    }

    function dbAdd(name) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        var result = tx.executeSql(
                                    'SELECT Name
                                     FROM Searched
                                     ORDER BY ID DESC
                                     LIMIT 1')

                        if (result.rows.length == 0) {
                            tx.executeSql('INSERT INTO Searched (Name) VALUES(?)', [ name ]);
                        } else if (result.rows.length && result.rows.item(0).Name !== name) {
                            tx.executeSql('INSERT INTO Searched (Name) VALUES(?)', [ name ]);
                        }
                    })

    }

    function dbReadAll(model) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.0", "", 1000000);
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT *
                         FROM Searched
                         ORDER BY ID DESC
                         LIMIT 10')

            for (var i = 0; i < results.rows.length; i++) {
                model.append({
                                 name: results.rows.item(i).Name
                             })
            }
        })
    }

    function dbClean(limit) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.0", "", 1000000);
        var searchCount

        db.transaction(
                    function(tx) {
                        var results = tx.executeSql('SELECT COUNT(Searched.ID) AS count
                                                     FROM Searched');

                        if (results.rows.length) {
                            searchCount = results.rows.item(0).count;
                        }
                    })

        var toRemove = searchCount - limit
        if (toRemove >= 0) {
            db.transaction(
                        function(tx) {
                            tx.executeSql('DELETE
                                           FROM Searched
                                           WHERE ID IN (Select ID FROM Searched LIMIT ?)', [ toRemove ]);
                        })
        }
    }
}
