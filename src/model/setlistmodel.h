#ifndef SETLISTMODEL_H
#define SETLISTMODEL_H

#include <memory>

#include <QAbstractItemModel>
#include <QSortFilterProxyModel>

#include "src/types/set.h"

class ModelsManager;

class SetListModel : public QAbstractListModel
{
    Q_OBJECT

    enum SetListRole
    {
        NameRole = Qt::UserRole + 1,
        IdRole,
        ImageRole
    };

public:
    explicit SetListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setList(SetListPtr sets);

    Q_INVOKABLE bool empty() const;

signals:
    void setsLoaded();

private:
    SetListPtr m_sets;
};

using SetListModelPtr = std::shared_ptr<SetListModel>;

#endif // SETLISTMODEL_H
