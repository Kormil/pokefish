#include "attack.h"

QString
Attack::name() const
{
  return m_name;
}

QString
Attack::damage() const
{
  return m_damage;
}

QString
Attack::text() const
{
  return m_text;
}

QStringList
Attack::costList() const
{
  return m_costList;
}

void
Attack::setName(const QString& value)
{
  m_name = value;
  emit dataChanged();
}

void
Attack::setDamage(const QString& value)
{
  m_damage = value;
  emit dataChanged();
}

void
Attack::setText(const QString& value)
{
  m_text = value;
  emit dataChanged();
}

void
Attack::setCostList(const QStringList& value)
{
  m_costList = value;
  emit dataChanged();
}
