#ifndef SET_H
#define SET_H

#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QString>
#include <map>
#include <memory>

class Set;
class SetList;

using SetPtr = std::shared_ptr<Set>;
using SetListPtr = std::shared_ptr<SetList>;

class Set : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString id READ id NOTIFY dataChanged)
  Q_PROPERTY(QString name READ name NOTIFY dataChanged)
  Q_PROPERTY(QString image READ imageUrl NOTIFY dataChanged)

public:
  Set() = default;
  Set& operator=(const Set&) = default;
  Set& operator=(Set&&) = default;

  void fromJson(QJsonObject& json);
  QString id() const;
  QString name() const;
  QString imageUrl() const;

signals:
  void dataChanged();

private:
  QString m_id;
  QString m_name;
  QString m_imageUrl;
};

class SetList : public QObject
{
  Q_OBJECT

public:
  explicit SetList(QObject* parent = nullptr);
  virtual ~SetList();

  std::size_t size() const;

  SetPtr get(int index);
  SetPtr get(QString id);
  int index(QString id) const;
  void append(const SetPtr& set);
  void appendList(SetListPtr& sets);
signals:
  void preItemAppended();
  void postItemAppended();

public slots:

private:
  std::vector<SetPtr> m_sets;
  std::map<QString, int> m_idToRow;
};

#endif // SET_H
