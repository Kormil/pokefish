#ifndef CARDLISTMODEL_H
#define CARDLISTMODEL_H

#include <memory>

#include <QAbstractItemModel>
#include <QSortFilterProxyModel>

#include "src/types/card.h"

class ModelsManager;
class CardListModel;

class SortCards : public QObject {
    Q_OBJECT
public:
    enum EnSortCards
    {
        ByName,
        ByType,
        BySupertype,
        ByNationalPokedexNumber
    };
    Q_ENUM(EnSortCards)
};

class CardListProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractListModel* cardListModel READ cardListModel WRITE setCardListModel)
    Q_PROPERTY(bool sorting READ sorting WRITE setSorting)
    Q_PROPERTY(SortCards::EnSortCards sortBy READ sortedBy WRITE setSortedBy)

public:
    CardListProxyModel(QObject *parent = nullptr);
    virtual bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    SortCards::EnSortCards sortedBy() const;
    void setSortedBy(const SortCards::EnSortCards &sortedBy);

    QAbstractListModel *cardListModel() const;
    void setCardListModel(QAbstractListModel *cardListModel);

    bool sorting() const;
    void setSorting(bool sorting);

private:
    QAbstractListModel * m_cardListModel;
    bool m_sorting = false;
    SortCards::EnSortCards m_sortedBy = SortCards::EnSortCards::ByName;
};

class CardListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum CardListRole
    {
        NameRole = Qt::UserRole + 1,
        IdRole,
        SuperTypeRole,
        SubTypeRole,
        SetRole,
        TypesRole,
        RarityRole,
        SmallImageRole,
        LargeImageRole,
        NationalPokedexNumberRole,
        HP,
        Counter
    };
    Q_ENUM(CardListRole)

    explicit CardListModel(QObject *parent = nullptr);
    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool exist(QString cardId) const;
    Q_INVOKABLE void append(QVariantMap obj);
    void append(CardPtr card, int count = 1);
    void appendList(CardListPtr cards);
    void setCardList(CardListPtr cards);

    Q_INVOKABLE void reset();
    Q_INVOKABLE Card* getRaw(QString id);

    CardPtr card(QString id);

signals:
    void cardsLoaded();

private:
    CardListPtr m_cards;
};

using CardListModelPtr = std::shared_ptr<CardListModel>;

#endif // CARDLISTMODEL_H
