#ifndef CONNECTION_H
#define CONNECTION_H

#include "request.h"
#include "searchparameters.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <mutex>
#include <string>

#include "model/cardlistmodel.h"
#include "model/setlistmodel.h"
#include "types/card.h"
#include "types/set.h"

class Connection
{
public:
  enum Errors
  {
    NoData = -1
  };

  Connection();

  virtual ~Connection() {}

  // Cards
  void searchCardsByName(SearchParameters* parameters,
                         std::function<void(CardListPtr)> handler);
  void searchCardsByName(const SearchParameters& parameters,
                         std::function<void(CardListPtr)> handler);
  void searchCardsById(const QString& cardId,
                       std::function<void(CardPtr)> handler);
  int searchCardsById(const std::vector<QString>& card_id_list,
                      std::function<void(int, CardListPtr)> handler);
  void searchCardsBySet(const QString& setId,
                        std::function<void(CardListPtr)> handler);

  // Sets
  void searchAllSets(std::function<void(SetListPtr)> handler);

  // Types
  void searchAllTypes(std::function<void(const QStringList&)> handler);
  void searchAllSubtypes(std::function<void(const QStringList&)> handler);

  Request* request(const QUrl& requestUrl);
  void deleteRequest(int serial);
  void clearRequests();

  QNetworkAccessManager* networkAccessManager();

protected:
  int nextSerial();

private:
  CardListPtr parseCards(const QJsonDocument& jsonDocument);
  CardPtr parseCard(const QJsonDocument& jsonDocument);
  SetListPtr parseSets(const QJsonDocument& jsonDocument);
  QStringList parseArrayOfStrings(const char* name,
                                  const QJsonDocument& jsonDocument);

  std::unique_ptr<QNetworkAccessManager> m_networkAccessManager;
  std::map<int, RequestPtr> m_networkRequests;
  std::atomic<int> m_serial = { 0 };

  std::mutex m_networkRequestsMutex;
};

using ConnectionPtr = std::shared_ptr<Connection>;

#endif // CONNECTION_H
