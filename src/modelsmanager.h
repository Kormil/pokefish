#ifndef MODELSMANAGER_H
#define MODELSMANAGER_H

#include "src/connection.h"
#include "model/cardlistmodel.h"
#include "model/setlistmodel.h"

class QQuickView;

class ModelsManager
{
public:
    ModelsManager();
    ~ModelsManager();

    void createModels();
    void deleteModels();
    void bindToQml(QQuickView *view);

    CardListModelPtr cardListModel() const;
    SetListModelPtr setListModel() const;

    void resetSearchModel();

    //cards
    void searchCardsByName(const QString& name, std::function<void(void)> callback);
    void searchCardsByIdList(const QStringList& idList, std::function<void(void)> callback);
    void searchCardsBySet(const QString& setId, std::function<void(void)> callback);

    //sets
    void searchAllSets(std::function<void(void)> callback);

private:
    CardListModelPtr m_cardListModel;
    CardListModelPtr m_searchedCardListModel;
    SetListModelPtr m_setListModel;
    ConnectionPtr m_connection;
};

#endif // MODELSMANAGER_H
