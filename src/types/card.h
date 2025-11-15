#ifndef CARD_H
#define CARD_H

#include "ability.h"
#include "attack.h"
#include "price.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QString>
#include <map>
#include <memory>

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
  Q_PROPERTY(QString largeImageUrl READ largeImageUrl NOTIFY dataChanged)
  Q_PROPERTY(QString hp READ hp NOTIFY dataChanged)

  Q_PROPERTY(int rulesSize READ rulesSize NOTIFY dataChanged)
  Q_PROPERTY(int abilitiesSize READ abilitiesSize NOTIFY dataChanged)
  Q_PROPERTY(int attackSize READ attackSize NOTIFY dataChanged)

  Q_PROPERTY(bool hasRetreatCost READ hasRetreatCost NOTIFY dataChanged)
  Q_PROPERTY(int retreatCost READ retreatCost NOTIFY dataChanged)
  Q_PROPERTY(QString weakness READ weakness NOTIFY dataChanged)
  Q_PROPERTY(QString weaknessValue READ weaknessValue NOTIFY dataChanged)
  Q_PROPERTY(QString resistances READ resistances NOTIFY dataChanged)
  Q_PROPERTY(QString resistancesValue READ resistancesValue NOTIFY dataChanged)

  Q_PROPERTY(
    int nationalPokedexNumber READ nationalPokedexNumber NOTIFY dataChanged)

public:
  Card() = default;
  Card(QVariantMap obj);

  void fromJson(QJsonObject& json);
  QString name() const;
  void setName(const QString& value);
  QString id() const;
  QString cardSet() const;
  QString rarity() const;
  QString type() const;
  QString subtype() const;
  QString supertype() const;
  QString smallImageUrl() const;
  QString largeImageUrl() const;
  QString hp() const;

  int rulesSize() const;
  Q_INVOKABLE QString rule(int index) const;
  QStringList rules() const;

  int abilitiesSize() const;
  Q_INVOKABLE Ability* ability(int index);

  int attackSize() const;
  Q_INVOKABLE Attack* attack(int index);

  Q_INVOKABLE QString prices(const QString& market_name,
                             PriceType::Value type,
                             PriceLevel::Value level);
  Q_INVOKABLE QString priceUrl(const QString& market_name);

  bool hasRetreatCost() const;
  int retreatCost() const;
  QString weakness() const;
  QString weaknessValue() const;
  QString resistances() const;
  QString resistancesValue() const;

  int nationalPokedexNumber() const;
  void setNationalPokedexNumber(int nationalPokedexNumber);

  QString ptcgoCode();
  QString cardNumber();
  void setCardNumber(QString number);

signals:
  void dataChanged();

private:
  QString m_id;
  QString m_name;
  QString m_cardSet;
  QString m_rarity;
  QStringList m_types;
  QString m_subtype;
  QString m_supertype;
  QString m_smallImageUrl;
  QString m_largeImageUrl;
  QString m_hp;

  std::vector<AbilityPtr> m_abilities;
  std::vector<AttackPtr> m_attacks;

  std::map<QString, MarketPricePtr> m_prices;

  bool m_hasRetreatCost = false;
  int m_retreatCost;
  QString m_weakness;
  QString m_weaknessValue;
  QString m_resistances;
  QString m_resistancesValue;

  bool m_hasAdditionalRule = false;
  QStringList m_additionalRules;

  int m_nationalPokedexNumber;

  // import/export
  QString ptcgo_code_;
  QString card_number_;
};

class CardList : public QObject
{
  Q_OBJECT

public:
  explicit CardList(QObject* parent = nullptr);
  virtual ~CardList();

  std::size_t size() const;

  CardPtr get(int index);
  CardPtr get(QString id);

  int counter(int index) const;
  int counter(QString id) const;

  int index(QString id) const;
  void append(const CardPtr& card, int counter = 1);
  void appendList(CardListPtr& cards);

  bool exist(QString id) const;

  QStringList idList() const;

signals:
  void preItemAppended();
  void postItemAppended();

public slots:

private:
  std::vector<CardPtr> m_cards;
  std::vector<int> cards_counters_;
  std::map<QString, int> m_idToRow;
};

#endif // CARD_H
