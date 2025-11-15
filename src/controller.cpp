#include "controller.h"

#include <QtQml>

Controller::Controller(QObject* parent)
  : QObject(parent)
{
}

Controller&
Controller::instance()
{
  static Controller instance;
  return instance;
}

QObject*
Controller::instance(QQmlEngine* engine, QJSEngine* scriptEngine)
{
  Q_UNUSED(engine)
  Q_UNUSED(scriptEngine)

  return &instance();
}

void
Controller::bindToQml(QQuickView* view)
{
  qmlRegisterSingletonType<Controller>(
    "Controller", 1, 0, "Controller", Controller::instance);
  qmlRegisterType<SearchParameters>("Controller", 1, 0, "SearchParameters");
}

void
Controller::setModelsManager(ModelsManager* modelsManager)
{
  m_modelsManager = modelsManager;
}

void
Controller::resetSearchResult()
{
  if (m_modelsManager) {
    m_modelsManager->resetSearchModel();
  }
}

void
Controller::searchCardsByName(QObject* object)
{
  emit searchStarted();

  SearchParameters* parameters = qobject_cast<SearchParameters*>(object);
  if (!parameters) {
    return;
  }

  if (parameters->m_name.isEmpty()) {
    emit searchCompleted();
    return;
  }

  if (m_modelsManager) {
    m_modelsManager->searchCardsByName(
      parameters, [this](CardListPtr) { emit searchCompleted(); });
  } else {
    emit searchCompleted();
  }
}

int
Controller::searchCardsByIdList(const QStringList& id_list)
{
  emit searchStarted();

  if (m_modelsManager) {
    return m_modelsManager->searchCardsByIdList(
      id_list, [this](int serial, CardListPtr) {
        emit searchWithSerialCompleted(serial);
      });
  } else {
    emit searchCompleted();
  }

  return 0;
}

void
Controller::searchCardsBySet(const QString& setId)
{
  emit searchStarted();

  if (setId.isEmpty()) {
    emit searchCompleted();
    return;
  }

  if (m_modelsManager) {
    m_modelsManager->searchCardsBySet(setId,
                                      [this]() { emit searchCompleted(); });
  } else {
    emit searchCompleted();
  }
}

void
Controller::searchAllSets()
{
  emit searchSetStarted();

  if (m_modelsManager) {
    m_modelsManager->searchAllSets([this]() { emit searchSetCompleted(); });
  } else {
    emit searchSetCompleted();
  }
}
