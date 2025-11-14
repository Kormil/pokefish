#include "ability.h"

QString
Ability::name() const
{
  return m_name;
}

QString
Ability::type() const
{
  return m_type;
}

QString
Ability::text() const
{
  return m_text;
}

void
Ability::setName(const QString& value)
{
  m_name = value;
  emit dataChanged();
}

void
Ability::setType(const QString& value)
{
  m_type = value;
  emit dataChanged();
}

void
Ability::setText(const QString& value)
{
  m_text = value;
  emit dataChanged();
}
