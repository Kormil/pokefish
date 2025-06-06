#ifndef SETTINGS_H
#define SETTINGS_H

#include <memory>
#include <QObject>
#include <QVariant>
#include <QSettings>

class QSettings;
class QJSEngine;
class QQmlEngine;

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool sortCards READ sortCards WRITE setSortCards NOTIFY sortingChanged)
    Q_PROPERTY(int sortCardsBy READ sortCardsBy WRITE setSortCardsBy NOTIFY sortingChanged)
    Q_PROPERTY(bool alwaysLargeImages READ alwaysLargeImages WRITE setAlwaysLargeImages NOTIFY alwaysLargeImagesChanged)

public:
    static QObject *instance(QQmlEngine *engine, QJSEngine *scriptEngine);
    static void bindToQml();

    Q_INVOKABLE QString license();

    bool sortCards() const;
    void setSortCards(bool value);

    int sortCardsBy() const;
    void setSortCardsBy(int value);

    bool alwaysLargeImages() const;
    void setAlwaysLargeImages(bool value);

signals:
    void sortingChanged();
    void alwaysLargeImagesChanged();

private:
    void migratedb();

    explicit Settings();
    std::unique_ptr<QSettings> m_settings;
};

#endif // SETTINGS_H
