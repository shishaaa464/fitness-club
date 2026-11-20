#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <QString>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>

class DataManager {
public:
    DataManager();

    bool saveData(const QJsonObject &jsonObj, const QString &filename = "fitness_data.json");

    QJsonObject loadData(const QString &filename = "fitness_data.json");
};

#endif // DATAMANAGER_H