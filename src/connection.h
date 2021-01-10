#ifndef CONNECTION_H
#define CONNECTION_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

#include <string>
#include <map>
#include <memory>
#include <mutex>
#include <iostream>
#include <functional>

#include "request.h"
#include "types/card.h"
#include "types/set.h"
#include "model/cardlistmodel.h"
#include "model/setlistmodel.h"

class Connection
{
public:
    enum Errors {
        NoData = -1
    };

    Connection();
    virtual ~Connection() {}

    //Cards
    void searchCardsByName(const QString& name, std::function<void(CardListPtr)> handler);
    void searchCardsById(const QString& cardId, std::function<void(CardPtr)> handler);
    void searchCardsBySet(const QString& setId, std::function<void(CardListPtr)> handler);

    //Sets
    void searchAllSets(std::function<void(SetListPtr)> handler);

    Request* request(const QUrl &requestUrl);
    void deleteRequest(int serial);
    void clearRequests();

    QNetworkAccessManager* networkAccessManager();
protected:
    int nextSerial();

private:
    CardListPtr parseCards(const QJsonDocument &jsonDocument);
    CardPtr parseCard(const QJsonDocument &jsonDocument);
    SetListPtr parseSets(const QJsonDocument &jsonDocument);

    std::unique_ptr<QNetworkAccessManager> m_networkAccessManager;
    std::map<int, RequestPtr> m_networkRequests;
    std::atomic<int> m_serial;

    std::mutex m_networkRequestsMutex;
};

using ConnectionPtr = std::shared_ptr<Connection>;

#endif // CONNECTION_H
