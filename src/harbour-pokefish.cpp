#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QGuiApplication>
#include <sailfishapp.h>

#include <sailfishapp.h>

#include "settings.h"
#include "src/modelsmanager.h"
#include "src/controller.h"
#include "src/deckimporter.h"
#include "src/deckexporter.h"
#include "src/networkaccessmanagerfactory.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-pokefish.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QGuiApplication * app = SailfishApp::application(argc, argv);
    QQuickView * view = SailfishApp::createView();

    NetworkAccessManagerFactory factory;

    ModelsManager modelsManager;
    modelsManager.createModels();
    modelsManager.bindToQml(view);

    Controller &controller = Controller::instance();
    controller.bindToQml(view);
    controller.setModelsManager(&modelsManager);

    DeckImporter::bindToQml();
    DeckImporter::setModelsManager(&modelsManager);

    DeckExporter::bindToQml();
    DeckExporter::setModelsManager(&modelsManager);

    Settings::bindToQml();

    view->engine()->setNetworkAccessManagerFactory(&factory);
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    int result = app->exec();

    view->destroy();

    return result;
}
