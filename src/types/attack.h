#ifndef ATTACK_H
#define ATTACK_H

#include <QObject>
#include <memory>

class Attack : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name MEMBER m_name NOTIFY dataChanged)
    Q_PROPERTY(QString damage MEMBER m_damage NOTIFY dataChanged)
    Q_PROPERTY(QString text MEMBER m_text NOTIFY dataChanged)
    Q_PROPERTY(QStringList costList MEMBER m_costList NOTIFY dataChanged)

public:
    QString name() const;
    QString damage() const;
    QString text() const;
    QStringList costList() const;

    void setName(const QString &value);
    void setDamage(const QString &value);
    void setText(const QString &value);
    void setCostList(const QStringList &value);

signals:
    void dataChanged();

private:
    QString m_name;
    QString m_damage;
    QString m_text;
    QStringList m_costList;
};

using AttackPtr = std::shared_ptr<Attack>;

#endif // ATTACK_H
