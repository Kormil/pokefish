#ifndef ABILITY_H
#define ABILITY_H

#include <QObject>
#include <memory>

class Ability : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString name MEMBER m_name NOTIFY dataChanged)
  Q_PROPERTY(QString type MEMBER m_type NOTIFY dataChanged)
  Q_PROPERTY(QString text MEMBER m_text NOTIFY dataChanged)

public:
  QString name() const;
  QString type() const;
  QString text() const;

  void setName(const QString& value);
  void setType(const QString& value);
  void setText(const QString& value);

signals:
  void dataChanged();

private:
  QString m_name;
  QString m_type;
  QString m_text;
};

using AbilityPtr = std::shared_ptr<Ability>;

#endif // ABILITY_H
