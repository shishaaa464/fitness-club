#include "datamanager.h"
#include <QDebug>

DataManager::DataManager() {}

bool DataManager::saveData(const QJsonObject &jsonObj, const QString &filename) {
    QFile saveFile(filename);
    if (!saveFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Не удалось открыть файл для сохранения данных!";
        return false;
    }

    QJsonDocument saveDoc(jsonObj);
    saveFile.write(saveDoc.toJson());
    saveFile.close();
    return true;
}

QJsonObject DataManager::loadData(const QString &filename) {
    QFile loadFile(filename);
    if (!loadFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Файл данных не найден, будет создан новый.";
        return QJsonObject();
    }

    QByteArray saveData = loadFile.readAll();
    loadFile.close();

    QJsonDocument loadDoc(QJsonDocument::fromJson(saveData));
    return loadDoc.object();
}