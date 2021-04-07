#include "cardlistmodel.h"
#include <QtQml>

CardListProxyModel::CardListProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
}

bool CardListProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    if (!m_sorting) {
        return false;
    }

    if (!source_right.isValid() || !source_left.isValid()) {
        return false;
    }

    auto roles = roleNames();
    if (m_sortedBy >= SortCards::ByType)
    {
        int role = roles.key("types");
        QVariant leftData = sourceModel()->data(source_left, role);
        QVariant rightData = sourceModel()->data(source_right, role);

        if (!leftData.isValid()) {
            return false;
        }

        if (!rightData.isValid()) {
            return true;
        }

        int result = QString::localeAwareCompare(leftData.toString(), rightData.toString());
        if (result != 0) {
            return result < 0;
        }
    }

    if (m_sortedBy >= SortCards::ByName)
    {
        int role = roles.key("name");
        QVariant leftData = sourceModel()->data(source_left, role);
        QVariant rightData = sourceModel()->data(source_right, role);

        return QString::localeAwareCompare(leftData.toString(), rightData.toString()) < 0;
    }

    return false;
}

QVariant CardListProxyModel::data(const QModelIndex &index, int role) const
{
    auto model = sourceModel();
    if (!index.isValid() || model == nullptr)
        return QVariant();

    auto mappedIndex = mapToSource(index);
    auto result = model->data(mappedIndex, role);
    return result;
}

QHash<int, QByteArray> CardListProxyModel::roleNames() const
{
    auto model = sourceModel();
    if (!model) {
        return QHash<int, QByteArray>();
    }

    return model->roleNames();
}

int CardListProxyModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || m_cardListModel == nullptr) {
        return 0;
    }

    return QSortFilterProxyModel::rowCount(parent);
}

SortCards::EnSortCards CardListProxyModel::sortedBy() const
{
    return m_sortedBy;
}

void CardListProxyModel::setSortedBy(const SortCards::EnSortCards &sortedBy)
{
    m_sortedBy = sortedBy;
    invalidate();
}

QAbstractListModel *CardListProxyModel::cardListModel() const
{
    return m_cardListModel;
}

void CardListProxyModel::setCardListModel(QAbstractListModel *cardListModel)
{
    m_cardListModel = cardListModel;

    setSourceModel(m_cardListModel);
    invalidateFilter();
    sort(0);
}

bool CardListProxyModel::sorting() const
{
    return m_sorting;
}

void CardListProxyModel::setSorting(bool sorting)
{
    m_sorting = sorting;
    invalidateFilter();
}

CardListModel::CardListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_cards = std::make_shared<CardList>();
}

int CardListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || m_cards == nullptr)
        return 0;

    return m_cards->size();
}

QVariant CardListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || m_cards == nullptr)
        return QVariant();

    const CardPtr card = m_cards->get(index.row());
    if (!card) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole: {
        return QVariant(card->name());
    }
    case CardListRole::IdRole: {
        return QVariant(card->id());
    }
    case CardListRole::SuperTypeRole: {
        return QVariant(card->supertype());
    }
    case CardListRole::SubTypeRole: {
        return QVariant(card->subtype());
    }
    case CardListRole::SetRole: {
        return QVariant(card->cardSet());
    }
    case CardListRole::TypesRole: {
        return QVariant(card->type());
    }
    case CardListRole::RarityRole: {
        return QVariant(card->rarity());
    }
    case CardListRole::SmallImageRole: {
        return QVariant(card->smallImageUrl());
    }
    }

    return QVariant();
}

QHash<int, QByteArray> CardListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::DisplayRole] = "name";
    names[CardListRole::IdRole] = "card_id";
    names[CardListRole::SuperTypeRole] = "super_type";
    names[CardListRole::SubTypeRole] = "sub_type";
    names[CardListRole::SetRole] = "set";
    names[CardListRole::TypesRole] = "types";
    names[CardListRole::RarityRole] = "rarity";
    names[CardListRole::SmallImageRole] = "small_image_url";
    return names;
}

void CardListModel::setCardList(CardListPtr cards)
{
    beginResetModel();

    if (m_cards) {
        m_cards->disconnect(this);
    }

    m_cards = std::move(cards);

    if (m_cards)
    {
        connect(m_cards.get(), &CardList::preItemAppended, this, [this]() {
            const int index = m_cards->size();
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(m_cards.get(), &CardList::postItemAppended, this, [this]() {
            endInsertRows();
        });
    }

    endResetModel();
    emit cardsLoaded();
}

Card* CardListModel::card(QString id) {
    if (!m_cards) {
        return nullptr;
    }

    auto cardPtr = m_cards->get(id);
    if (cardPtr) {
        auto cardRawPtr = cardPtr.get();
        QQmlEngine::setObjectOwnership(cardRawPtr, QQmlEngine::CppOwnership);
        return cardRawPtr;
    }

    return nullptr;
}

bool CardListModel::exist(QString cardId) const {
    if (!m_cards) {
        return false;
    }

    return m_cards->exist(cardId);
}

void CardListModel::append(CardPtr card) {
    if (!m_cards) {
        return ;
    }

    return m_cards->append(card);
}

void CardListModel::appendList(CardListPtr cards) {
    if (!m_cards) {
        return ;
    }

    return m_cards->appendList(cards);
}
