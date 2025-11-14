#include "price.h"

QString MarketPrice::name() const {
    return name_;
}

QString MarketPrice::url() const {
    return url_;
}

QString MarketPrice::updatedAt() const {
    return updated_at_;
}

MarketPricePtr MarketPrice::fromJson(const QString &name, QJsonObject &json) {
    auto market_prices = std::make_shared<MarketPrice>();

    bool has_market = json.contains(name);
    if (!has_market) {
        return nullptr;
    }

    auto market_json = json[name].toObject();

    market_prices->name_ = name;
    market_prices->url_ = market_json["url"].toString();
    market_prices->updated_at_ = market_json["updatedAt"].toString();

    auto proces_json = market_json["prices"].toObject();

    if (name == "tcgplayer") {
        market_prices->prices_[static_cast<size_t>(PriceType::Normal)] = pricesFromJson("normal", proces_json);
        market_prices->prices_[static_cast<size_t>(PriceType::Holofoil)] = pricesFromJson("holofoil", proces_json);
        market_prices->prices_[static_cast<size_t>(PriceType::ReverseHolofoil)] = pricesFromJson("reverseHolofoil", proces_json);
    } else {
        market_prices->prices_[static_cast<size_t>(PriceType::Normal)] = pricesFromJsonCardMarket("normal", proces_json);
    }

    return market_prices;
}

MarketPrice::PriceLevels MarketPrice::pricesFromJson(const QString &name, QJsonObject &json) {
    PriceLevels prices;

    prices[static_cast<size_t>(PriceLevel::Low)] = "";
    prices[static_cast<size_t>(PriceLevel::High)] = "";
    prices[static_cast<size_t>(PriceLevel::Market)] = "";

    bool has_price = json.contains(name);
    if (has_price) {
        prices[static_cast<size_t>(PriceLevel::Low)] = QString::number(json[name].toObject()["low"].toDouble());
        prices[static_cast<size_t>(PriceLevel::High)] = QString::number(json[name].toObject()["high"].toDouble());
        prices[static_cast<size_t>(PriceLevel::Market)] = QString::number(json[name].toObject()["market"].toDouble());
    }

    return prices;
}

MarketPrice::PriceLevels MarketPrice::pricesFromJsonCardMarket(const QString &name, QJsonObject &json) {
    PriceLevels prices;

    prices[static_cast<size_t>(PriceLevel::Low)] = QString::number(json["lowPrice"].toDouble());
    prices[static_cast<size_t>(PriceLevel::Market)] = QString::number(json["averageSellPrice"].toDouble());
    prices[static_cast<size_t>(PriceLevel::High)] = "";

    return prices;
}

QString MarketPrice::price(PriceType::Value type, PriceLevel::Value level) const {
    return prices_[static_cast<size_t>(type)][static_cast<size_t>(level)];
}
