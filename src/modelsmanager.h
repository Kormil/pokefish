#ifndef MODELSMANAGER_H
#define MODELSMANAGER_H

#include <QStringListModel>

#include "src/connection.h"
#include "model/cardlistmodel.h"
#include "model/setlistmodel.h"

class QQuickView;

class ModelsManager
{
public:
    enum class Mode { reset, append };

    ModelsManager();
    ~ModelsManager();

    void createModels();
    void deleteModels();
    void bindToQml(QQuickView *view);

    CardListModelPtr cardListModel() const;
    SetListModelPtr setListModel() const;

    void resetSearchModel();

    //cards
    void searchCardsByName(SearchParameters *parameters, std::function<void (CardListPtr)> callback, Mode mode = Mode::reset);
    void searchCardsByName(const SearchParameters &parameters, std::function<void(CardListPtr)> callback, Mode mode = Mode::reset);
    void searchCardsByIdList(const QStringList& idList, std::function<void(void)> callback);
    void searchCardsBySet(const QString& setId, std::function<void(void)> callback, Mode mode = Mode::reset);

    //sets
    void searchAllSets(std::function<void(void)> callback);

    //types
    void searchAllTypes();
    void searchAllSubtypes();

private:
    CardListModelPtr m_cardListModel;
    CardListModelPtr m_searchedCardListModel;
    SetListModelPtr m_setListModel;
    QStringListModel m_typesListModel;
    QStringListModel m_subtypesListModel;

    ConnectionPtr m_connection;
};

#endif // MODELSMANAGER_H
