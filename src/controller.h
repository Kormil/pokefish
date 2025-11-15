#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "modelsmanager.h"
#include "searchparameters.h"

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>

class Controller : public QObject
{
  Q_OBJECT

public:
  static Controller& instance();
  static QObject* instance(QQmlEngine* engine, QJSEngine* scriptEngine);
  static void bindToQml(QQuickView* view);

  void setModelsManager(ModelsManager* modelsManager);
  Q_INVOKABLE void resetSearchResult();
  Q_INVOKABLE void searchCardsByName(QObject* object);
  Q_INVOKABLE int searchCardsByIdList(const QStringList& idList);
  Q_INVOKABLE void searchCardsBySet(const QString& setId);

  Q_INVOKABLE void searchAllSets();

signals:
  void searchStarted();
  void searchCompleted();
  void searchWithSerialCompleted(int serial);

  void searchSetStarted();
  void searchSetCompleted();

private:
  explicit Controller(QObject* parent = nullptr);

  ModelsManager* m_modelsManager = nullptr;
};

#endif // CONTROLLER_H
