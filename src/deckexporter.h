#ifndef DECKEXPORTER_H
#define DECKEXPORTER_H

#include <vector>

#include <QObject>
#include <QString>
#include <QQmlEngine>

#include "src/modelsmanager.h"
#include "model/cardlistmodel.h"

class DeckExporter : public QObject
{
    Q_OBJECT

public:
    DeckExporter();

    static void bindToQml();
    static void setModelsManager(ModelsManager* modelsManager);

    Q_INVOKABLE int loadData(QAbstractListModel* model);

    Q_INVOKABLE QString text();
    Q_INVOKABLE void reset();

    void addCard(const CardPtr& card, int counter);

signals:
    void exportStarted();
    void exportFinished();

private:
    std::vector<QString> pokemons_;
    std::vector<QString> trainers_;
    std::vector<QString> energies_;

    QAbstractListModel* model_;

    static ModelsManager* models_manager_;
};

#endif // DECKEXPORTER_H
