#include "connection.h"

#include "request.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <iostream>

Connection::Connection()
{
  m_networkAccessManager = std::make_unique<QNetworkAccessManager>();
  auto diskCache = new QNetworkDiskCache(m_networkAccessManager.get());
  diskCache->setCacheDirectory(
    QStandardPaths::writableLocation(QStandardPaths::CacheLocation)
      .append("/network"));
  m_networkAccessManager->setCache(diskCache);
}

void
Connection::deleteRequest(int serial)
{
  std::lock_guard<std::mutex> lock(m_networkRequestsMutex);
  m_networkRequests.erase(m_networkRequests.find(serial));
}

QNetworkAccessManager*
Connection::networkAccessManager()
{
  return m_networkAccessManager.get();
}

int
Connection::nextSerial()
{
  m_serial = m_serial + 1;
  return m_serial;
}

void
Connection::clearRequests()
{
  m_networkAccessManager->deleteLater();
}

Request*
Connection::request(const QUrl& requestUrl)
{
  std::lock_guard<std::mutex> lock(m_networkRequestsMutex);

  int serial = nextSerial();

  RequestPtr requestPtr = std::make_unique<Request>(requestUrl, this);

  requestPtr->setSerial(serial);
  m_networkRequests[serial] = std::move(requestPtr);

  return m_networkRequests[serial].get();
}

void
Connection::searchCardsByName(SearchParameters* parameters,
                              std::function<void(CardListPtr)> handler)
{
  qDebug() << "searchCardsByName *";
  QString parsedParameters;

  if (!parameters || !parameters->parse(parsedParameters)) {
    handler(CardListPtr{});
    return;
  }

  QString url = "https://api.pokemontcg.io/v2/cards?q=" + parsedParameters;
  qDebug() << url;
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       qCritical() << "CONNECTION ERROR";
                       handler(CardListPtr{});
                     } else {
                       qDebug() << "Download finished";
                       CardListPtr cards =
                         parseCards(QJsonDocument::fromJson(responseArray));
                       qDebug() << "Cards parsed";
                       handler(std::move(cards));
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

void
Connection::searchCardsByName(const SearchParameters& parameters,
                              std::function<void(CardListPtr)> handler)
{
  qDebug() << "searchCardsByName &";
  QString parsedParameters;

  if (!parameters.parse(parsedParameters)) {
    handler(CardListPtr{});
    return;
  }

  QString url = "https://api.pokemontcg.io/v2/cards?q=" + parsedParameters;
  qDebug() << url;
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       qCritical() << "CONNECTION ERROR";
                       handler(CardListPtr{});
                     } else {
                       qDebug() << "Download finished";
                       CardListPtr cards =
                         parseCards(QJsonDocument::fromJson(responseArray));
                       qDebug() << "Cards parsed";
                       handler(std::move(cards));
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

void
Connection::searchCardsById(const QString& cardId,
                            std::function<void(CardPtr)> handler)
{
  QString url = "https://api.pokemontcg.io/v2/cards/" + cardId;
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       std::cout << "CONNECTION ERROR" << std::endl;
                       handler(nullptr);
                     } else {
                       CardPtr card =
                         parseCard(QJsonDocument::fromJson(responseArray));
                       handler(std::move(card));
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

void
Connection::searchCardsById(const std::vector<QString>& card_id_list,
                            std::function<void(CardListPtr)> handler)
{
  QString url = "https://api.pokemontcg.io/v2/cards?q=";

  for (const auto& card_id : card_id_list) {
    url.append("id:");
    url.append(card_id);

    if (card_id_list.back() != card_id) {
      url.append(" OR ");
    }
  }

  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       std::cout << "CONNECTION ERROR" << std::endl;
                       handler(CardListPtr{});
                     } else {
                       qDebug() << "Download finished";
                       CardListPtr cards =
                         parseCards(QJsonDocument::fromJson(responseArray));
                       qDebug() << "Cards parsed";
                       handler(std::move(cards));
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

void
Connection::searchCardsBySet(const QString& setId,
                             std::function<void(CardListPtr)> handler)
{
  QString url = "https://api.pokemontcg.io/v2/cards?q=set.id:" + setId;
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       std::cout << "CONNECTION ERROR" << std::endl;
                       handler(CardListPtr{});
                     } else {
                       CardListPtr cards =
                         parseCards(QJsonDocument::fromJson(responseArray));
                       handler(std::move(cards));
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

CardListPtr
Connection::parseCards(const QJsonDocument& jsonDocument)
{
  if (jsonDocument.isNull()) {
    return CardListPtr(nullptr);
  }

  CardListPtr cards = std::make_shared<CardList>();

  const auto& object = jsonDocument.object();
  const auto& data = object["data"];
  if (data.isUndefined()) {
    return cards;
  }

  QJsonArray results = data.toArray();

  for (const auto& result : results) {
    auto card = std::make_shared<Card>();
    auto cardJson = result.toObject();
    card->fromJson(cardJson);

    cards->append(card);
  }

  return std::move(cards);
}

CardPtr
Connection::parseCard(const QJsonDocument& jsonDocument)
{
  if (jsonDocument.isNull()) {
    return CardPtr(nullptr);
  }

  const auto& object = jsonDocument.object();
  const auto& data = object["data"];
  auto card = std::make_shared<Card>();
  auto cardJson = data.toObject();
  card->fromJson(cardJson);

  return std::move(card);
}

void
Connection::searchAllSets(std::function<void(SetListPtr)> handler)
{
  QString url = "https://api.pokemontcg.io/v2/sets";
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       std::cout << "CONNECTION ERROR" << std::endl;
                       handler(SetListPtr{});
                     } else {
                       SetListPtr sets =
                         parseSets(QJsonDocument::fromJson(responseArray));
                       handler(std::move(sets));
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

SetListPtr
Connection::parseSets(const QJsonDocument& jsonDocument)
{
  if (jsonDocument.isNull()) {
    return SetListPtr(nullptr);
  }

  SetListPtr sets = std::make_shared<SetList>();

  const auto& object = jsonDocument.object();
  const auto& data = object["data"];
  if (data.isUndefined()) {
    return sets;
  }

  QJsonArray reverseResults = data.toArray();
  QJsonArray results;

  for (const auto& result : reverseResults) {
    results.push_front(result);
  }

  for (const auto& result : results) {
    auto set = std::make_shared<Set>();
    auto setJson = result.toObject();
    set->fromJson(setJson);

    sets->append(set);
  }

  return std::move(sets);
}

void
Connection::searchAllTypes(std::function<void(const QStringList&)> handler)
{
  QString url = "https://api.pokemontcg.io/v2/types";
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       std::cout << "CONNECTION ERROR" << std::endl;
                       handler(QStringList{});
                     } else {
                       QStringList types = parseArrayOfStrings(
                         "data", QJsonDocument::fromJson(responseArray));
                       handler(types);
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

void
Connection::searchAllSubtypes(std::function<void(const QStringList&)> handler)
{
  QString url = "https://api.pokemontcg.io/v2/subtypes";
  QUrl searchUrl(url);

  Request* requestRaw = request(searchUrl);

  QObject::connect(requestRaw,
                   &Request::finished,
                   [this, requestRaw, handler](
                     Request::Status status, const QByteArray& responseArray) {
                     if (status == Request::ERROR) {
                       std::cout << "CONNECTION ERROR" << std::endl;
                       handler(QStringList{});
                     } else {
                       QStringList subtypes = parseArrayOfStrings(
                         "data", QJsonDocument::fromJson(responseArray));
                       handler(subtypes);
                     }

                     deleteRequest(requestRaw->serial());
                   });
  requestRaw->run();
}

QStringList
Connection::parseArrayOfStrings(const char* name,
                                const QJsonDocument& jsonDocument)
{
  QStringList types;

  if (jsonDocument.isNull()) {
    return types;
  }

  auto response = jsonDocument.object()[name];
  if (response.isUndefined()) {
    return types;
  }

  QJsonArray results = response.toArray();
  for (const auto& result : results) {
    auto type = result.toString();
    types.append(type);
  }

  return types;
}
