#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

#include "modelsmanager.h"

class Controller : public QObject
{
    Q_OBJECT
public:
    static Controller& instance();
    static QObject *instance(QQmlEngine *engine, QJSEngine *scriptEngine);
    static void bindToQml(QQuickView *view);

    void setModelsManager(ModelsManager* modelsManager);
    Q_INVOKABLE void resetSearchResult();
    Q_INVOKABLE void searchCardsByName(const QString &name);
    Q_INVOKABLE void searchCardsByIdList(const QStringList &idList);
    Q_INVOKABLE void searchCardsBySet(const QString &setId);

    Q_INVOKABLE void searchAllSets();

signals:
    void searchStarted();
    void searchCompleted();

    void searchSetStarted();
    void searchSetCompleted();

private:
    explicit Controller(QObject *parent = nullptr);

    ModelsManager* m_modelsManager = nullptr;
};

#endif // CONTROLLER_H
