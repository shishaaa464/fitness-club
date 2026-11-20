#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "clientlistmodel.h"
#include "reportmanager.h"
#include "notificationmanager.h"
#include "visitmodel.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;


    ClientListModel clientModel;
    ReportManager reportManager;
    NotificationManager notificationManager;

    VisitModel visitModel;
    engine.rootContext()->setContextProperty("visitModel", &visitModel);
    engine.rootContext()->setContextProperty("clientModel", &clientModel);
    engine.rootContext()->setContextProperty("reportManager", &reportManager);
    engine.rootContext()->setContextProperty("notificationManager", &notificationManager);

    const QUrl url("qrc:/qt/qml/FitnessClubApp/Main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}