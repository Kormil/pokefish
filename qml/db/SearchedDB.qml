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
                        tx.executeSql('DROP TABLE Searched');
                    })
    }

    function dbAdd(parameters) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(
                    function(tx) {
                        var result = tx.executeSql(
                                    'SELECT Name, Type, Subtype
                                     FROM Searched
                                     ORDER BY ID DESC
                                     LIMIT 1')

                        if (result.rows.length === 0 ||
                                (result.rows.item(0).Name !== parameters.name ||
                                 result.rows.item(0).Type !== parameters.type ||
                                 result.rows.item(0).Subtype !== parameters.subtype)) {
                            tx.executeSql('INSERT INTO Searched (Name, Type, Subtype) VALUES(?, ?, ?)',
                                          [ parameters.name, parameters.type, parameters.subtype ]);
                        }
                    })

    }

    function dbReadAll(model) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT *
                         FROM Searched
                         ORDER BY ID DESC
                         LIMIT 50')

            for (var i = 0; i < results.rows.length; i++) {
                model.append({
                                 name: results.rows.item(i).Name,
                                 type: results.rows.item(i).Type,
                                 subtype: results.rows.item(i).Subtype
                             })
            }
        })
    }

    function dbClean(limit) {
        var db = LocalStorage.openDatabaseSync("PokefishDB", "1.2.0", "", 1000000);
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
