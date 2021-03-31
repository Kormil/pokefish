#include "modelsmanager.h"

#include <QtCore>
#include <QObject>
#include <QQuickView>
#include <QtQml>

#include "src/types/card.h"
#include "src/types/attack.h"
#include "src/types/ability.h"

#include "src/searchparameters.h"

ModelsManager::ModelsManager() :
    m_cardListModel(nullptr),
    m_searchedCardListModel(nullptr)
{
}

ModelsManager::~ModelsManager()
{
    deleteModels();
}

void ModelsManager::createModels()
{
    m_cardListModel = std::make_shared<CardListModel>();
    m_searchedCardListModel = std::make_shared<CardListModel>();

    m_setListModel = std::make_shared<SetListModel>();

    m_connection = std::make_shared<Connection>();

    searchAllTypes();
    searchAllSubtypes();
    std::cout << "Models created" << std::endl;
}

void ModelsManager::deleteModels()
{
    std::cout << "Models deleted" << std::endl;
}

void ModelsManager::bindToQml(QQuickView * view)
{
    qmlRegisterType<CardListModel>("CardListModel", 1, 0, "CardListModel");
    qmlRegisterType<SetListModel>("SetListModel", 1, 0, "SetListModel");
    view->rootContext()->setContextProperty(QStringLiteral("searchedCardListModel"), m_searchedCardListModel.get());
    view->rootContext()->setContextProperty(QStringLiteral("setListModel"), m_setListModel.get());
    view->rootContext()->setContextProperty(QStringLiteral("typesListModel"), &m_typesListModel);
    view->rootContext()->setContextProperty(QStringLiteral("subtypesListModel"), &m_subtypesListModel);

    qmlRegisterType<Card>("Card", 1, 0, "Card");
    qmlRegisterType<Attack>("Card", 1, 0, "Attack");
    qmlRegisterType<Ability>("Card", 1, 0, "Ability");
    qmlRegisterType<Card>("Set", 1, 0, "Set");
}

CardListModelPtr ModelsManager::cardListModel() const {
    return m_cardListModel;
}

SetListModelPtr ModelsManager::setListModel() const {
    return m_setListModel;
}

void ModelsManager::searchCardsByName(SearchParameters* parameters, std::function<void(void)> callback) {
    m_connection->searchCardsByName(parameters, [=](CardListPtr cards) {
        m_searchedCardListModel->setCardList(cards);
        callback();
    });
}

void ModelsManager::searchCardsByIdList(const QStringList& idList, std::function<void(void)> callback) {
    if (!m_searchedCardListModel) {
        return;
    }

    if (m_searchedCardListModel)

    //TODO przerobić żeby ten callback był jak już wszystkie się pobiorą
    for (const auto& id: idList) {
        if (m_searchedCardListModel->exist(id)) {
            callback();
            return;
        }

        m_connection->searchCardsById(id, [=](CardPtr card) {
            m_searchedCardListModel->append(card);
            callback();
        });
    }
}

void ModelsManager::searchCardsBySet(const QString &setId, std::function<void(void)> callback) {
    m_connection->searchCardsBySet(setId, [=](CardListPtr cards) {
        m_searchedCardListModel->setCardList(cards);
        callback();
    });
}

void ModelsManager::searchAllSets(std::function<void(void)> callback) {
    m_connection->searchAllSets([=](SetListPtr sets) {
        m_setListModel->setList(sets);
        callback();
    });
}

void ModelsManager::searchAllTypes() {
    m_connection->searchAllTypes([=](const QStringList& types) {
        QStringList typesWithAny = types;
        typesWithAny.sort();
        typesWithAny.push_front("Any");

        m_typesListModel.setStringList(typesWithAny);
    });
}

void ModelsManager::searchAllSubtypes() {
    m_connection->searchAllSubtypes([=](const QStringList& subtypes) {
        QStringList subtypesWithAny = subtypes;
        subtypesWithAny.sort();
        subtypesWithAny.push_front("Any");

        m_subtypesListModel.setStringList(subtypesWithAny);
    });
}

void ModelsManager::resetSearchModel()
{
    m_searchedCardListModel->setCardList(nullptr);
}
