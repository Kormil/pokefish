#include "deckexporter.h"

#include <QFile>
#include <QtQml>

ModelsManager* DeckExporter::models_manager_ = nullptr;

DeckExporter::DeckExporter()
  : QObject(nullptr)
{
}

void
DeckExporter::bindToQml()
{
  qmlRegisterType<DeckExporter>("DeckExporter", 1, 0, "DeckExporter");
}

void
DeckExporter::setModelsManager(ModelsManager* modelsManager)
{
  models_manager_ = modelsManager;
}

void
DeckExporter::reset()
{
  pokemons_.clear();
  energies_.clear();
  trainers_.clear();
}

int
DeckExporter::loadData(QAbstractListModel* model)
{
  reset();

  if (!model || !model->rowCount()) {
    return 0;
  }

  model_ = model;

  emit exportStarted();

  QStringList cards_to_download;
  std::map<QString, int> counters;
  for (auto row = 0; row < model->rowCount(); ++row) {
    auto card_id =
      model->data(model->index(row, 0), CardListModel::IdRole).toString();
    auto counter =
      model->data(model->index(row, 0), CardListModel::Counter).toInt();

    cards_to_download.push_back(card_id);
    counters[card_id] = counter;
  }

  models_manager_->searchCardsByIdList(
    cards_to_download, [this, counters](int, CardListPtr cards) {
      if (!cards) {
        emit exportFinished();
      }

      for (int row = 0; row < cards->size(); ++row) {
        auto card = cards->get(row);
        int counter = counters.at(card->id());
        addCard(card, counter);
      }
      emit exportFinished();
    });

  return 0;
}

void
DeckExporter::addCard(const CardPtr& card, int counter)
{
  QString line = QString("%1 %2 %3 %4")
                   .arg(counter)
                   .arg(card->name())
                   .arg(card->ptcgoCode())
                   .arg(card->cardNumber());

  if (card->supertype() == "Pokémon") {
    pokemons_.push_back(line);
  } else if (card->supertype() == "Trainer") {
    trainers_.push_back(line);
  } else if (card->supertype() == "Energy") {
    if (card->subtype() == "Basic") {
      if (card->name().contains("Green", Qt::CaseInsensitive)) {
        card->setCardNumber("1");
      } else if (card->name().contains("Fire", Qt::CaseInsensitive)) {
        card->setCardNumber("2");
      } else if (card->name().contains("Water", Qt::CaseInsensitive)) {
        card->setCardNumber("3");
      } else if (card->name().contains("Lightning", Qt::CaseInsensitive)) {
        card->setCardNumber("4");
      } else if (card->name().contains("Psychic", Qt::CaseInsensitive)) {
        card->setCardNumber("5");
      } else if (card->name().contains("Fighting", Qt::CaseInsensitive)) {
        card->setCardNumber("6");
      } else if (card->name().contains("Darkness", Qt::CaseInsensitive)) {
        card->setCardNumber("7");
      } else if (card->name().contains("Metal", Qt::CaseInsensitive)) {
        card->setCardNumber("8");
      } else if (card->name().contains("Fairy", Qt::CaseInsensitive)) {
        card->setCardNumber("9");
      }

      // hack for old cards
      QString ptcgo_code = "Energy";
      if (card->ptcgoCode().contains("sve", Qt::CaseInsensitive)) {
        ptcgo_code = "SVE";
      }

      line = QString("%1 %2 %3 %4")
               .arg(counter)
               .arg(card->name())
               .arg(ptcgo_code)
               .arg(card->cardNumber());
    }

    energies_.push_back(line);
  }
}

QString
DeckExporter::text()
{
  int pokemon_counter = pokemons_.size();
  int trainer_counter = trainers_.size();
  int energy_counter = energies_.size();

  QString ret;

  if (pokemon_counter) {
    ret.append(QString("Pokemon - %1\n").arg(pokemon_counter));
    for (const auto& pokemon_line : pokemons_) {
      ret.append(pokemon_line);
      ret.append("\n");
    }
  }

  if (trainer_counter) {
    ret.append(QString("Trainer - %1\n").arg(trainer_counter));
    for (const auto& trainer_line : trainers_) {
      ret.append(trainer_line);
      ret.append("\n");
    }
  }

  if (energy_counter) {
    ret.append(QString("Energy - %1\n").arg(energy_counter));
    for (const auto& energy_line : energies_) {
      ret.append(energy_line);
      ret.append("\n");
    }
  }

  return ret;
}
