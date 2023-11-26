#include "filesaver.h"

#include <QtQml>
#include <QFile>

FileSaver::FileSaver(QObject *parent) :
    QObject(parent) {

}

FileSaver& FileSaver::instance()
{
    static FileSaver instance;
    return instance;
}

void FileSaver::bindToQml(QQuickView *view) {
    qmlRegisterSingletonType<FileSaver>("FileSaver", 1, 0, "FileSaver", FileSaver::instance);
}

QObject *FileSaver::instance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return &instance();
}

bool FileSaver::exists(const QString& path, QString name) {
    name.append(".txt");

    QDir directory(path);
    QFile file(directory.filePath(name));

    return file.exists();
}

bool FileSaver::saveTo(const QString& data, const QString& path, QString name, bool force) {
    name.append(".txt");

    QDir directory(path);
    QFile file(directory.filePath(name));

    if (file.exists() && !force) {
        emit fileExists();
        return false;
    }

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        return false;
    }

    QTextStream out(&file);
    out << data;
    return true;
}
