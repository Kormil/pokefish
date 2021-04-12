#include "settings.h"
#include <iostream>
#include <QtQml>
#include <QVariant>
#include <sailfishapp.h>

#include "model/cardlistmodel.h"

#define CARDS_SORT_SETTINGS_PATH QStringLiteral("cards/sort")
#define CARDS_SORT_BY_SETTINGS_PATH QStringLiteral("cards/sort_by")
#define NETWORK_ALWAYS_LARGE_IMAGES_SETTINGS_PATH QStringLiteral("network/always_large_images")

Settings::Settings(QObject *parent) :
    m_settings(std::make_unique<QSettings>(parent))
{

}

int Settings::sortCardsBy() const
{
    return m_settings->value(CARDS_SORT_BY_SETTINGS_PATH, 0).toInt();
}

void Settings::setSortCardsBy(int value)
{
    if (sortCardsBy() != value) {
        m_settings->setValue(CARDS_SORT_BY_SETTINGS_PATH, value);
        emit sortingChanged();
    }
}

bool Settings::alwaysLargeImages() const
{
    return m_settings->value(NETWORK_ALWAYS_LARGE_IMAGES_SETTINGS_PATH, false).toBool();
}

void Settings::setAlwaysLargeImages(bool value)
{
    if (alwaysLargeImages() != value) {
        m_settings->setValue(NETWORK_ALWAYS_LARGE_IMAGES_SETTINGS_PATH, value);
        emit alwaysLargeImagesChanged();
    }
}

bool Settings::sortCards() const
{
    return m_settings->value(CARDS_SORT_SETTINGS_PATH, false).toBool();
}

void Settings::setSortCards(bool value)
{
    if (sortCards() != value) {
        m_settings->setValue(CARDS_SORT_SETTINGS_PATH, value);
        emit sortingChanged();
    }
}

QObject *Settings::instance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    static Settings instance;
    return &instance;
}

QString Settings::license()
{
    QString licenseFile = SailfishApp::pathTo(QString("LICENSE")).toLocalFile();

    if (!QFile::exists(licenseFile)) {
        return "License not found.";
    }

    QFile file(licenseFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "Could not open: " + licenseFile;

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    return content;
}

void Settings::bindToQml()
{
    qmlRegisterSingletonType<Settings>("Settings", 1, 0, "Settings", Settings::instance);
}
