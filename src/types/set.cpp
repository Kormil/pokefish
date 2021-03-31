#include "set.h"

#include <algorithm>
#include <QtQml>

QString Set::name() const {
    return m_name;
}

QString Set::id() const {
    return m_id;
}

QString Set::imageUrl() const {
    return m_imageUrl;
}

void Set::fromJson(QJsonObject &json) {
    QString id = json["id"].toString();
    QString name = json["name"].toString();
    QString imageUrl = json["images"].toObject()["logo"].toString();

    m_id = id;
    m_name = name;
    m_imageUrl = imageUrl;
}

SetList::SetList(QObject *parent) : QObject(parent)
{

}


SetList::~SetList()
{
}

std::size_t SetList::size() const
{
    return m_sets.size();
}

SetPtr SetList::get(int index)
{
    if (index >= m_sets.size()) {
        return nullptr;
    }

    return m_sets[index];
}

SetPtr SetList::get(QString id)
{
    auto row = m_idToRow.find(id);
    if (row != m_idToRow.end()) {
        return m_sets[row->second];
    }

    return nullptr;
}

int SetList::index(QString id) const {
    auto row = m_idToRow.find(id);
    if (row != m_idToRow.end()) {
        return row->second;
    }

    return -1;
}

void SetList::append(const SetPtr &set)
{
    if (set == nullptr)
        return;

    auto setIt = m_idToRow.find(set->id());

    if (m_idToRow.end() == setIt)
    {
        emit preItemAppended();
        int row = m_sets.size();
        m_sets.push_back(set);
        m_idToRow[set->id()] = row;
        emit postItemAppended();
    }
}

void SetList::appendList(SetListPtr &sets)
{
    for (auto& set: sets->m_sets)
    {
        append(set);
    }

    sets = nullptr;
}
