#ifndef CARDLISTMODEL_H
#define CARDLISTMODEL_H

#include <memory>

#include <QAbstractItemModel>
#include <QSortFilterProxyModel>

#include "src/types/card.h"

class ModelsManager;

class CardListModel : public QAbstractListModel
{
    Q_OBJECT

    enum CardListRole
    {
        NameRole = Qt::UserRole + 1,
        IdRole,
        SuperTypeRole,
        SubTypeRole,
        SetRole,
        TypesRole,
        RarityRole,
        SmallImageRole
    };

public:
    explicit CardListModel(QObject *parent = nullptr);
    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool exist(QString cardId) const;
    void append(CardPtr card);
    void appendList(CardListPtr cards);
    void setCardList(CardListPtr cards);

    Q_INVOKABLE Card* card(QString id);

signals:
    void cardsLoaded();

private:
    CardListPtr m_cards;
};

using CardListModelPtr = std::shared_ptr<CardListModel>;

#endif // CARDLISTMODEL_H
