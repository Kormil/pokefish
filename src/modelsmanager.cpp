#include "modelsmanager.h"

#include <QObject>
#include <QQuickView>
#include <QtCore>
#include <QtQml>

#include "src/searchparameters.h"
#include "src/types/ability.h"
#include "src/types/attack.h"
#include "src/types/card.h"
#include "src/types/price.h"

ModelsManager::ModelsManager()
  : m_cardListModel(nullptr)
  , m_searchedCardListModel(nullptr)
{
}

ModelsManager::~ModelsManager()
{
  deleteModels();
}

void
ModelsManager::createModels()
{
  m_cardListModel = std::make_shared<CardListModel>();
  m_searchedCardListModel = std::make_shared<CardListModel>();

  m_setListModel = std::make_shared<SetListModel>();

  m_connection = std::make_shared<Connection>();

  searchAllTypes();
  searchAllSubtypes();
  std::cout << "Models created" << std::endl;
}

void
ModelsManager::deleteModels()
{
  std::cout << "Models deleted" << std::endl;
}

void
ModelsManager::bindToQml(QQuickView* view)
{
  qRegisterMetaType<CardListModel::CardListRole>("CardListModel::CardListRole");

  qmlRegisterType<CardListModel>("CardListModel", 1, 0, "CardListModel");
  qmlRegisterType<CardListProxyModel>(
    "CardListModel", 1, 0, "CardListProxyModel");
  qmlRegisterUncreatableType<SortCards>(
    "CardListModel", 1, 0, "SortCards", "Cannot create SortCard in QML");
  qmlRegisterType<SetListModel>("SetListModel", 1, 0, "SetListModel");

  view->rootContext()->setContextProperty(
    QStringLiteral("searchedCardListModel"), m_searchedCardListModel.get());
  view->rootContext()->setContextProperty(QStringLiteral("setListModel"),
                                          m_setListModel.get());
  view->rootContext()->setContextProperty(QStringLiteral("typesListModel"),
                                          &m_typesListModel);
  view->rootContext()->setContextProperty(QStringLiteral("subtypesListModel"),
                                          &m_subtypesListModel);

  qmlRegisterType<Card>("Card", 1, 0, "Card");
  qmlRegisterType<Attack>("Card", 1, 0, "Attack");

  qmlRegisterUncreatableType<MarketPrice>(
    "MarketPrice", 1, 0, "MarketPrice", "Only for enums");
  qmlRegisterUncreatableType<PriceType>(
    "MarketPrice", 1, 0, "PriceType", "Only for enums");
  qmlRegisterUncreatableType<PriceLevel>(
    "MarketPrice", 1, 0, "PriceLevel", "Only for enums");

  qRegisterMetaType<PriceType::Value>();
  qRegisterMetaType<PriceLevel::Value>();

  qmlRegisterType<Ability>("Card", 1, 0, "Ability");
  qmlRegisterType<Card>("Set", 1, 0, "Set");
}

CardListModelPtr
ModelsManager::cardListModel() const
{
  return m_cardListModel;
}

SetListModelPtr
ModelsManager::setListModel() const
{
  return m_setListModel;
}

void
ModelsManager::searchCardsByName(
  SearchParameters* parameters,
  std::function<void(CardListPtr cards)> callback,
  Mode mode)
{
  m_connection->searchCardsByName(parameters, [=](CardListPtr cards) {
    if (mode == Mode::reset) {
      m_searchedCardListModel->setCardList(cards);
    } else if (mode == Mode::append) {
      m_searchedCardListModel->appendList(cards);
    }
    callback(cards);
  });
}

void
ModelsManager::searchCardsByName(
  const SearchParameters& parameters,
  std::function<void(CardListPtr cards)> callback,
  Mode mode)
{
  m_connection->searchCardsByName(parameters, [=](CardListPtr cards) {
    if (mode == Mode::reset) {
      m_searchedCardListModel->setCardList(cards);
    } else if (mode == Mode::append) {
      m_searchedCardListModel->appendList(cards);
    }
    callback(cards);
  });
}

void
ModelsManager::searchCardsByIdList(
  const QStringList& idList,
  std::function<void(CardListPtr cards)> callback)
{
  if (!m_searchedCardListModel) {
    return;
  }

  std::vector<QString> cards_to_download;
  auto card_list = std::make_shared<CardList>();

  // skip already downloaded
  for (const auto& id : idList) {
    auto card = m_searchedCardListModel->card(id);
    if (card) {
      card_list->append(card);
      continue;
    }

    cards_to_download.push_back(id);
  }

  if (cards_to_download.empty()) {
    callback(card_list);
    return;
  }

  // download the rest
  if (cards_to_download.size() == 1) {
    m_connection->searchCardsById(cards_to_download.front(), [=](CardPtr card) {
      m_searchedCardListModel->append(card);
      card_list->append(card);

      callback(card_list);
    });

    return;
  }

  m_connection->searchCardsById(cards_to_download, [=](CardListPtr cards) {
    m_searchedCardListModel->appendList(cards);
    card_list->appendList(cards);

    callback(card_list);
  });
}

void
ModelsManager::searchCardsBySet(const QString& setId,
                                std::function<void(void)> callback,
                                Mode mode)
{
  m_connection->searchCardsBySet(setId, [=](CardListPtr cards) {
    if (mode == Mode::reset) {
      m_searchedCardListModel->setCardList(cards);
    } else if (mode == Mode::append) {
      m_searchedCardListModel->appendList(cards);
    }
    callback();
  });
}

void
ModelsManager::searchAllSets(std::function<void(void)> callback)
{
  m_connection->searchAllSets([=](SetListPtr sets) {
    m_setListModel->setList(sets);
    callback();
  });
}

void
ModelsManager::searchAllTypes()
{
  m_connection->searchAllTypes([=](const QStringList& types) {
    QStringList typesWithAny = types;
    typesWithAny.sort();
    typesWithAny.push_front("Any");

    m_typesListModel.setStringList(typesWithAny);
  });
}

void
ModelsManager::searchAllSubtypes()
{
  m_connection->searchAllSubtypes([=](const QStringList& subtypes) {
    QStringList subtypesWithAny = subtypes;
    subtypesWithAny.sort();
    subtypesWithAny.push_front("Any");

    m_subtypesListModel.setStringList(subtypesWithAny);
  });
}

void
ModelsManager::resetSearchModel()
{
  m_searchedCardListModel->setCardList(nullptr);
}
