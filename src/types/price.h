#ifndef PRICE_H
#define PRICE_H

#include <QJsonObject>
#include <QObject>
#include <memory>

class MarketPrice;
using MarketPricePtr = std::shared_ptr<MarketPrice>;

class PriceType : public QObject
{
  Q_OBJECT

public:
  enum Value
  {
    Normal,
    Holofoil,
    ReverseHolofoil,
    FirstEditionNormal,
    FirstEditionHolofoil,

    PriceTypeSize
  };
  Q_ENUM(Value)
};

class PriceLevel : public QObject
{
  Q_OBJECT

public:
  enum Value
  {
    Low,
    High,
    Market,

    PriceLevelSize
  };
  Q_ENUM(Value)
};

class MarketPrice : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString name READ name NOTIFY dataChanged)
  Q_PROPERTY(QString url READ url NOTIFY dataChanged)
  Q_PROPERTY(QString updated_at READ updatedAt NOTIFY dataChanged)

public:
  using Price = QString;
  using PriceLevels =
    std::array<Price, static_cast<size_t>(PriceLevel::Value::PriceLevelSize)>;
  using Prices =
    std::array<PriceLevels,
               static_cast<size_t>(PriceType::Value::PriceTypeSize)>;

  QString name() const;
  QString url() const;
  QString updatedAt() const;

  QString price(PriceType::Value type, PriceLevel::Value level) const;

  static MarketPricePtr fromJson(const QString& name, QJsonObject& json);
  static MarketPrice::PriceLevels pricesFromJson(const QString& name,
                                                 QJsonObject& json);
  static MarketPrice::PriceLevels pricesFromJsonCardMarket(const QString& name,
                                                           QJsonObject& json);

signals:
  void dataChanged();

private:
  QString name_;
  QString url_;
  QString updated_at_;

  Prices prices_;
};

#endif // PRICE_H
