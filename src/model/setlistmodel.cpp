#include "setlistmodel.h"

SetListModel::SetListModel(QObject* parent)
  : QAbstractListModel(parent)
  , m_sets(nullptr)
{
}

int
SetListModel::rowCount(const QModelIndex& parent) const
{
  if (parent.isValid() || m_sets == nullptr) {
    return 0;
  }

  return m_sets->size();
}

QVariant
SetListModel::data(const QModelIndex& index, int role) const
{
  if (!index.isValid() || m_sets == nullptr) {
    return QVariant();
  }

  const SetPtr set = m_sets->get(index.row());
  if (!set) {
    return QVariant();
  }

  switch (role) {
    case Qt::DisplayRole: {
      return QVariant(set->name());
    }
    case SetListRole::NameRole: {
      return QVariant(set->name());
    }
    case SetListRole::IdRole: {
      return QVariant(set->id());
    }
    case SetListRole::ImageRole: {
      return QVariant(set->imageUrl());
    }
  }

  return QVariant();
}

QHash<int, QByteArray>
SetListModel::roleNames() const
{
  QHash<int, QByteArray> names;
  names[Qt::DisplayRole] = "name";
  names[SetListRole::IdRole] = "set_id";
  names[SetListRole::ImageRole] = "image";
  return names;
}

void
SetListModel::setList(SetListPtr sets)
{
  beginResetModel();

  if (m_sets) {
    m_sets->disconnect(this);
  }

  m_sets = std::move(sets);

  if (m_sets) {
    connect(m_sets.get(), &SetList::preItemAppended, this, [this]() {
      const int index = m_sets->size();
      beginInsertRows(QModelIndex(), index, index);
    });

    connect(m_sets.get(), &SetList::postItemAppended, this, [this]() {
      endInsertRows();
    });
  }

  endResetModel();
  emit setsLoaded();
}

bool
SetListModel::empty() const
{
  if (m_sets == nullptr) {
    return true;
  }

  return m_sets->size();
}
