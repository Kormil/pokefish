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

QString Card::hp() const {
    return m_hp;
}

bool Card::hasAdditionalText() const {
    return m_hasAdditionalText;
}

QString Card::additionalText() const {
    return m_additionalText;
}

bool Card::hasAbility() const {
    return m_hasAbility;
}

void Card::setHasAbility(bool value) {
    m_hasAbility = value;
}

QString Card::abilityName() const {
    return m_abilityName;
}

void Card::setAbilityName(const QString &value) {
    m_abilityName = value;
}

QString Card::abilityType() const {
    return m_abilityType;
}

void Card::setAbilityType(const QString &value) {
    m_abilityType = value;
}

QString Card::abilityText() const {
    return m_abilityText;
}

void Card::setAbilityText(const QString &value) {
    m_abilityText = value;
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

void Card::fromJson(QJsonObject &json) {
    QString id = json["id"].toString();
    QString name = json["name"].toString();
    QString set = json["set"].toString();
    QString rarity = json["rarity"].toString();
    QString subtype = json["subtype"].toString();
    QString supertype = json["supertype"].toString();
    auto typeJsonArray = json["types"].toArray();
    QStringList types;
    for (auto typeJson: typeJsonArray) {
        auto type = typeJson.toString();
        types.push_back(type);
    }
    QString smallImageUrl = json["imageUrl"].toString();
    QString hp = json["hp"].toString();

    m_id = id;
    m_name = name;
    m_cardSet = set;
    m_rarity = rarity;
    m_subtype = subtype;
    m_supertype = supertype;
    m_types = types;
    m_smallImageUrl = smallImageUrl;
    m_hp = hp;

    m_hasAdditionalText = json.contains("text");
    if (m_hasAdditionalText) {
        auto textJsonArray = json["text"].toArray();
        m_additionalText = textJsonArray[0].toString();
    }

    m_hasAbility = json.contains("ability");
    if (m_hasAbility) {
        auto ability = json["ability"].toObject();
        m_abilityName = ability["name"].toString();
        m_abilityType = ability["type"].toString();
        m_abilityText = ability["text"].toString();
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

int CardList::index(QString id) const {
    auto row = m_idToRow.find(id);
    if (row != m_idToRow.end()) {
        return row->second;
    }

    return -1;
}

void CardList::append(const CardPtr &card)
{
    if (card == nullptr)
        return;

    auto cardIt = m_idToRow.find(card->id());

    if (m_idToRow.end() == cardIt)
    {
        emit preItemAppended();
        int row = m_cards.size();
        m_cards.push_back(card);
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
