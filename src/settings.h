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
public:
    static QObject *instance(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE QString license();

    static void bindToQml();

private:
    explicit Settings(QObject *parent = nullptr);
    std::unique_ptr<QSettings> m_settings;
};

#endif // SETTINGS_H
