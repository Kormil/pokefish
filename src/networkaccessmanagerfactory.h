#ifndef NETWORKACCESSMANAGERFACTORY_H
#define NETWORKACCESSMANAGERFACTORY_H

#include <QQmlNetworkAccessManagerFactory>
#include <QNetworkAccessManager>
#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QDebug>

class NetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory
{
public:
    NetworkAccessManagerFactory() = default;

public:
    QNetworkAccessManager *create(QObject *parent) override {
        auto manager = new QNetworkAccessManager(parent);
        auto diskCache = new QNetworkDiskCache(manager);
        diskCache->setCacheDirectory(QStandardPaths::writableLocation(QStandardPaths::CacheLocation)
                                     .append("/network"));
        manager->setCache(diskCache);
        return manager;
    }
};

#endif // NETWORKACCESSMANAGERFACTORY_H
