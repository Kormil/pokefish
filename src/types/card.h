#ifndef CARD_H
#define CARD_H

#include <memory>
#include <map>

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>

#include "attack.h"

class Card;
class CardList;

using CardPtr = std::shared_ptr<Card>;
using CardListPtr = std::shared_ptr<CardList>;

class Card : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY dataChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY dataChanged)
    Q_PROPERTY(QString set READ cardSet NOTIFY dataChanged)
    Q_PROPERTY(QString rarity READ rarity NOTIFY dataChanged)
    Q_PROPERTY(QString type READ type NOTIFY dataChanged)
    Q_PROPERTY(QString subtype READ subtype NOTIFY dataChanged)
    Q_PROPERTY(QString supertype READ supertype NOTIFY dataChanged)
    Q_PROPERTY(QString smallImageUrl READ smallImageUrl NOTIFY dataChanged)
    Q_PROPERTY(QString hp READ hp NOTIFY dataChanged)

    Q_PROPERTY(bool hasAdditionalText READ hasAdditionalText NOTIFY dataChanged)
    Q_PROPERTY(QString additionalText READ additionalText NOTIFY dataChanged)

    Q_PROPERTY(bool hasAbility READ hasAbility WRITE setHasAbility NOTIFY abilityChanged)
    Q_PROPERTY(QString abilityName READ abilityName WRITE setAbilityName NOTIFY abilityChanged)
    Q_PROPERTY(QString abilityType READ abilityType WRITE setAbilityType NOTIFY abilityChanged)
    Q_PROPERTY(QString abilityText READ abilityText WRITE setAbilityText NOTIFY abilityChanged)

    Q_PROPERTY(int attackSize READ attackSize NOTIFY dataChanged)

    Q_PROPERTY(bool hasRetreatCost READ hasRetreatCost NOTIFY dataChanged)
    Q_PROPERTY(int retreatCost READ retreatCost NOTIFY dataChanged)
    Q_PROPERTY(QString weakness READ weakness NOTIFY dataChanged)
    Q_PROPERTY(QString weaknessValue READ weaknessValue NOTIFY dataChanged)
    Q_PROPERTY(QString resistances READ resistances NOTIFY dataChanged)
    Q_PROPERTY(QString resistancesValue READ resistancesValue NOTIFY dataChanged)

public:
    Card() = default;
    Card& operator=(const Card&) = default;
    Card& operator=(Card&&) = default;

    void fromJson(QJsonObject& json);
    QString name() const;
    void setName(const QString &value);
    QString id() const;
    QString cardSet() const;
    QString rarity() const;
    QString type() const;
    QString subtype() const;
    QString supertype() const;
    QString smallImageUrl() const;
    QString hp() const;

    bool hasAdditionalText() const;
    QString additionalText() const;

    bool hasAbility() const;
    void setHasAbility(bool value);
    QString abilityName() const;
    void setAbilityName(const QString &value);
    QString abilityType() const;
    void setAbilityType(const QString &value);
    QString abilityText() const;
    void setAbilityText(const QString &value);

    int attackSize() const;
    Q_INVOKABLE Attack* attack(int index);

    bool hasRetreatCost() const;
    int retreatCost() const;
    QString weakness() const;
    QString weaknessValue() const;
    QString resistances() const;
    QString resistancesValue() const;

signals:
    void dataChanged();
    void abilityChanged();

private:
    QString m_id;
    QString m_name;
    QString m_cardSet;
    QString m_rarity;
    QStringList m_types;
    QString m_subtype;
    QString m_supertype;
    QString m_smallImageUrl;
    QString m_hp;

    bool m_hasAbility = false;
    QString m_abilityName;
    QString m_abilityType;
    QString m_abilityText;

    std::vector<AttackPtr> m_attacks;

    bool m_hasRetreatCost = false;
    int m_retreatCost;
    QString m_weakness;
    QString m_weaknessValue;
    QString m_resistances;
    QString m_resistancesValue;

    bool m_hasAdditionalText = false;
    QString m_additionalText;
};

class CardList : public QObject
{
    Q_OBJECT
public:
    explicit CardList(QObject *parent = nullptr);
    virtual ~CardList();

    std::size_t size() const;

    CardPtr get(int index);
    CardPtr get(QString id);
    int index(QString id) const;
    void append(const CardPtr &card);
    void appendList(CardListPtr &cards);

    bool exist(QString id) const;
signals:
    void preItemAppended();
    void postItemAppended();

public slots:

private:
    std::vector<CardPtr> m_cards;
    std::map<QString, int> m_idToRow;
};

#endif // CARD_H
