#include "card.h"

#include <algorithm>
#include <QtQml>

QString Card::name() const {
    return m_name;
}

void Card::setName(const QString &value) {
    m_name = value;
    emit dataChanged();
}

QString Card::id() const {
    return m_id;
}

QString Card::cardSet() const {
    return m_cardSet;
}

QString Card::type() const {
    return m_types.join(" ");
}

QString Card::rarity() const {
    return m_rarity;
}

QString Card::subtype() const {
    return m_subtype;
}

QString Card::supertype() const {
    return m_supertype;
}

QString Card::smallImageUrl() const {
    return m_smallImageUrl;
}

QString Card::largeImageUrl() const {
    return m_largeImageUrl;
}

QString Card::hp() const {
    return m_hp;
}

int Card::rulesSize() const {
    return m_additionalRules.size();
}

QString Card::rule(int index) const {
    if (index < 0 || index >= m_additionalRules.size()) {
        return QString();
    }

    return m_additionalRules[index];
}

int Card::abilitiesSize() const {
    return m_abilities.size();
}

Ability* Card::ability(int index) {
    if (index < 0 || index >= m_abilities.size()) {
        return nullptr;
    }

    auto abilityPtr = m_abilities[index];
    if (abilityPtr) {
        auto abilityRawPtr = abilityPtr.get();
        QQmlEngine::setObjectOwnership(abilityRawPtr, QQmlEngine::CppOwnership);
        return abilityRawPtr;
    }

    return nullptr;
}

int Card::attackSize() const {
    return m_attacks.size();
}

Attack* Card::attack(int index) {
    if (index < 0 || index >= m_attacks.size()) {
        return nullptr;
    }

    auto attackPtr = m_attacks[index];
    if (attackPtr) {
        auto attackRawPtr = attackPtr.get();
        QQmlEngine::setObjectOwnership(attackRawPtr, QQmlEngine::CppOwnership);
        return attackRawPtr;
    }

    return nullptr;
}

bool Card::hasRetreatCost() const {
    return m_hasRetreatCost;
}

int Card::retreatCost() const {
    return m_retreatCost;
}

QString Card::weakness() const {
    return m_weakness;
}

QString Card::weaknessValue() const {
    return m_weaknessValue;
}

QString Card::resistances() const {
    return m_resistances;
}

QString Card::resistancesValue() const {
    return m_resistancesValue;
}

int Card::nationalPokedexNumber() const
{
    return m_nationalPokedexNumber;
}

void Card::setNationalPokedexNumber(int nationalPokedexNumber)
{
    m_nationalPokedexNumber = nationalPokedexNumber;
    emit dataChanged();
}

void Card::fromJson(QJsonObject &json) {
    QString id = json["id"].toString();
    QString name = json["name"].toString();
    QString set = json["set"].toObject()["name"].toString();
    QString rarity = json["rarity"].toString();
    auto subtypeJsonArray = json["subtypes"].toArray();

    QString subtype;
    for (auto subtypeJson: subtypeJsonArray) {
       subtype = subtypeJson.toString();
    }

    QString supertype = json["supertype"].toString();
    auto typeJsonArray = json["types"].toArray();
    QStringList types;
    for (auto typeJson: typeJsonArray) {
        auto type = typeJson.toString();
        types.push_back(type);
    }
    QString smallImageUrl = json["images"].toObject()["small"].toString();
    QString largeImageUrl = json["images"].toObject()["large"].toString();
    QString hp = json["hp"].toString();

    m_id = id;
    m_name = name;
    m_cardSet = set;
    m_rarity = rarity;
    m_subtype = subtype;
    m_supertype = supertype;
    m_types = types;
    m_smallImageUrl = smallImageUrl;
    m_largeImageUrl = largeImageUrl;
    m_hp = hp;

    bool hasAdditionalRule = json.contains("rules");
    if (hasAdditionalRule) {
        auto rulesJsonArray = json["rules"].toArray();
        for (auto ruleJson: rulesJsonArray) {
            QString rule = ruleJson.toString();
            m_additionalRules.push_back(rule);
        }
    }

    bool hasAbility = json.contains("abilities");
    if (hasAbility) {
        auto abilitiesJsonArray = json["abilities"].toArray();
        for (auto abilitiesJson: abilitiesJsonArray) {
            AbilityPtr ability = std::make_shared<Ability>();
            auto abilityJObject = abilitiesJson.toObject();
            ability->setName(abilityJObject["name"].toString());
            ability->setType(abilityJObject["type"].toString());
            ability->setText(abilityJObject["text"].toString());

            m_abilities.push_back(std::move(ability));
        }
    }

    auto attacksJsonArray = json["attacks"].toArray();
    for (auto attackJson: attacksJsonArray) {
        auto attackJObject = attackJson.toObject();
        AttackPtr attack = std::make_shared<Attack>();
        attack->setName(attackJObject["name"].toString());
        attack->setDamage(attackJObject["damage"].toString());
        attack->setText(attackJObject["text"].toString());

        auto costJsonArray = attackJObject["cost"].toArray();
        QStringList costs;
        for (auto costJson: costJsonArray) {
            auto cost = costJson.toString();
            costs.push_back(cost);
        }
        attack->setCostList(costs);

        m_attacks.push_back(std::move(attack));
    }

    auto weaknessesJsonArray = json["weaknesses"].toArray();
    for (auto weaknessJson: weaknessesJsonArray) {
        auto weaknessJObject = weaknessJson.toObject();
        m_weakness = weaknessJObject["type"].toString();
        m_weaknessValue = weaknessJObject["value"].toString();
        break;
    }

    auto resistancesJsonArray = json["resistances"].toArray();
    for (auto resistanceJson: resistancesJsonArray) {
        auto resistanceJObject = resistanceJson.toObject();
        m_resistances = resistanceJObject["type"].toString();
        m_resistancesValue = resistanceJObject["value"].toString();
        break;
    }

    m_hasRetreatCost = json.contains("convertedRetreatCost");
    if (m_hasRetreatCost) {
        int retreatCost = json["convertedRetreatCost"].toInt();
        m_retreatCost = retreatCost;
    }

    auto nationalPokedexNumberJsonArray = json["nationalPokedexNumbers"].toArray();
    for (auto numberJson: nationalPokedexNumberJsonArray) {
       m_nationalPokedexNumber = numberJson.toInt();
       break; //TODO should get all number not only first one
    }
}

CardList::CardList(QObject *parent) : QObject(parent)
{

}


CardList::~CardList()
{
}

std::size_t CardList::size() const
{
    return m_cards.size();
}

CardPtr CardList::get(int index)
{
    if (index >= m_cards.size()) {
        return nullptr;
    }

    return m_cards[index];
}

CardPtr CardList::get(QString id)
{
    auto row = m_idToRow.find(id);
    if (row != m_idToRow.end()) {
        return m_cards[row->second];
    }

    return nullptr;
}

int CardList::counter(int index) const {
    if (index >= m_cards.size()) {
        return 0;
    }

    return cards_counters_[index];
}

int CardList::counter(QString id) const {
    auto row = m_idToRow.find(id);
    if (row != m_idToRow.end()) {
        return cards_counters_[row->second];
    }

    return 0;
}

int CardList::index(QString id) const {
    auto row = m_idToRow.find(id);
    if (row != m_idToRow.end()) {
        return row->second;
    }

    return -1;
}

void CardList::append(const CardPtr &card, int counter)
{
    if (card == nullptr)
        return;

    auto cardIt = m_idToRow.find(card->id());

    if (m_idToRow.end() == cardIt) {
        emit preItemAppended();
        int row = m_cards.size();
        m_cards.push_back(card);
        cards_counters_.push_back(counter);
        m_idToRow[card->id()] = row;
        emit postItemAppended();
    }
}

void CardList::appendList(CardListPtr &cards)
{
    for (auto& card: cards->m_cards)
    {
        append(card);
    }

    cards = nullptr;
}

bool CardList::exist(QString id) const {
    auto cardIt = m_idToRow.find(id);
    if (m_idToRow.end() == cardIt) {
        return false;
    }

    return true;
}
