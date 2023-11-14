#include "deckimporter.h"

#include <QtQml>

ModelsManager* DeckImporter::models_manager_ = nullptr;

DeckImporter::DeckImporter() : QObject(nullptr) {
    imported_cards_ = std::make_shared<CardList>();
    card_list_model_ = std::make_shared<CardListModel>();

    card_list_model_->setCardList(imported_cards_);
}

int DeckImporter::loadData(const QString &text) {
    const auto& data = text.split("\n", QString::SkipEmptyParts);

    const auto& cards = parseImportedDeck(data);
    if (cards.size()) {
        cards_ = cards;
        return cards_.size();
    }

    return 0;
}

int DeckImporter::loadData(const QUrl &file) {

}

void DeckImporter::start()
{
    if (!models_manager_) {
        qWarning() << "No models manager";
        return;
    }

    //reset imported cards before start downloading
    already_downloaded = 0;

    emit importStarted(cards_.size());

    connect(this, &DeckImporter::importedCard, [this]() {
        if (already_downloaded >= cards_.size()) {
            qInfo() << "Importing cards are end";
            emit importedAllCards();
            //deleteLater();
        }
    });

    for (auto& card: cards_) {
        SearchParameters parameters;
        parameters.m_name = card.card_name;
        parameters.m_ptcgoSeriesCode = card.series;
        parameters.m_cardNumber = card.card_number;

        models_manager_->searchCardsByName(parameters, [this, &card](CardListPtr cards) {
            if (!cards || !cards->size()) {
                qWarning() << "No cards";
            } else if (cards->size() == 1) {
                auto downloaded_card = cards->get(0);
                qWarning() << card.card_name;
                imported_cards_->append(downloaded_card, card.counter);
            } else {
                qWarning() << "Downloaded too many cards";
            }

            ++already_downloaded;
            emit importedCard(already_downloaded);

        }, ModelsManager::Mode::append);
    }
}

std::vector<DeckImporter::ImportedCard> DeckImporter::parseImportedDeck(const QStringList &imported) {
    std::vector<ImportedCard> ret;
    for (const auto& line: imported) {
        if (line.startsWith("**")) {
            continue;
        }

        if (line.startsWith("##")) {
            continue;
        }

        ImportedCard card;
        if (parseLineFromDeck(line, card)) {
            qDebug() << card.counter << " " << card.card_name << " " << card.series << " " << card.card_number;
            ret.push_back(card);
        }

        continue;
    }

    return ret;
}

bool DeckImporter::parseLineFromDeck(const QString& line, ImportedCard& parsed_line) {
    QStringList tmp_parsed_line = line.split(' ', QString::SkipEmptyParts);

    if (tmp_parsed_line.size() < 4) {
        return false;
    }

    //Parse star
    if (tmp_parsed_line.front() == "*") {
        tmp_parsed_line.removeFirst();
    }

    //Parse counter
    bool ok;
    auto counter = tmp_parsed_line.front().toInt(&ok);

    if (!ok) {
        return false;
    } else {
        tmp_parsed_line.removeFirst();
    }

    //Parse card number
    auto card_number = tmp_parsed_line.last();
    tmp_parsed_line.removeLast();

    //Parse series
    auto series = tmp_parsed_line.last();
    tmp_parsed_line.removeLast();

    //Parse name
    auto name = tmp_parsed_line.join(" ");
    name.prepend("\"");
    name.append("\"");

    parsed_line = {counter, name, series, card_number};
    return true;
}

void DeckImporter::bindToQml()
{
    qmlRegisterType<DeckImporter>("DeckImporter", 1, 0, "DeckImporter");
}

void DeckImporter::setModelsManager(ModelsManager* modelsManager) {
    models_manager_ = modelsManager;
}

int DeckImporter::alreadyDownloaded() {
    return already_downloaded;
}

QAbstractListModel *DeckImporter::importedCards() {
    return card_list_model_.get();
}
