#ifndef REQUEST_H
#define REQUEST_H

#include <memory>

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

class Connection;

class Request : public QObject
{
    Q_OBJECT
public:
    enum Status
    {
        SUCCESS,
        ERROR
    };

    Request(const QUrl& url, Connection *connection);
    void run();

    void addHeader(const QByteArray& key, const QByteArray& value);
    QList<QPair<QByteArray, QByteArray> > &getResponseHeaders();

    ~Request()
    {
        networkReply->deleteLater();
    }

    int serial() const;
    void setSerial(int serial);

private slots:
    void timeout();
    void responseFinished(QNetworkReply::NetworkError error, QString errorString);

private:
    QNetworkRequest m_networkRequest;
    QTimer m_requestTimer;
    Connection *m_connection;
    QNetworkReply* networkReply;
    QByteArray responseArray;
    QList<QPair<QByteArray, QByteArray>> responseHeaders;
    int m_serial;

signals:
    void finished(Status, const QByteArray&);
};

using PatameterList = std::map<QString, QString>;
using RequestPtr = std::unique_ptr<Request>; 

#endif //REQUEST_H
