#include "settings.h"
#include <iostream>
#include <QtQml>
#include <QVariant>
#include <sailfishapp.h>

Settings::Settings(QObject *parent) :
    m_settings(std::make_unique<QSettings>(parent))
{

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
