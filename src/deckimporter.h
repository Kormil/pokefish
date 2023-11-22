#ifndef DECKIMPORTER_H
#define DECKIMPORTER_H

#include <vector>
#include <atomic>
#include <mutex>

#include <QVector>
#include <QString>
#include <QObject>
#include <QFile>

#include "src/modelsmanager.h"

class DeckImporter : public QObject
{
    Q_OBJECT

    enum class Type {
        POKEMON,
        TRAINER,
        ENERGY
    };

    struct ImportedCard {
        int counter;
        QString card_name;
        QString series;
        QString card_number;
        Type type;
        QString api_card_id;
    };

    Q_PROPERTY(int alreadyDownloaded READ alreadyDownloaded NOTIFY importedCard)
    Q_PROPERTY(int downloadErrors READ downloadErrors NOTIFY importedCard)
    Q_PROPERTY(QAbstractListModel* importedCards READ importedCards NOTIFY importedCard)

public:
    DeckImporter();

    static void bindToQml();
    static void setModelsManager(ModelsManager* modelsManager);

    Q_INVOKABLE int loadData(const QString& text);
    Q_INVOKABLE int loadData(const QUrl& file);

    Q_INVOKABLE void start();
    //Q_INVOKABLE QStringList cardIdList();

    QAbstractListModel *importedCards();

    int alreadyDownloaded();
    int downloadErrors();

signals:
    void importStarted(int count);
    void importedCard(int count);
    void importedAllCards();

private:
    std::vector<ImportedCard> parseImportedDeck(const QStringList& imported);
    bool parseLineFromDeck(const QString& line, ImportedCard& parsed_line);
    ImportedCard parseEnergy(int counter, QString name, QString series, QString card_number);

    std::vector<ImportedCard> cards_;

    CardListPtr imported_cards_;
    CardListModelPtr card_list_model_;

    std::mutex mtx_;
    std::atomic_uint already_downloaded = {0};
    std::atomic_uint successfull_downloaded = {0};
    std::atomic_uint download_errors_ = {0};

    static ModelsManager* models_manager_;
};

#endif // DECKIMPORTER_H
