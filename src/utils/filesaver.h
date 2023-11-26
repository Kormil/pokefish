#ifndef FILESAVER_H
#define FILESAVER_H

#include <QObject>
#include <QQmlEngine>

class QQuickView;

class FileSaver : public QObject
{
    Q_OBJECT

public:
    static FileSaver& instance();
    static QObject *instance(QQmlEngine *engine, QJSEngine *scriptEngine);

    static void bindToQml(QQuickView *view);
    
    Q_INVOKABLE bool exists(const QString& path, QString name);
    Q_INVOKABLE bool saveTo(const QString& data, const QString& path, QString name, bool force);

signals:
    void fileExists();

private:
    explicit FileSaver(QObject *parent = nullptr);
};

#endif // FILESAVER_H
