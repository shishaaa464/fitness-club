#include "visitmodel.h"
#include <QDateTime>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

const QString VISITS_FILE = "visits_data.json";

VisitModel::VisitModel(QObject *parent) : QAbstractListModel(parent) {
    loadFromFile();
}

int VisitModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return m_visits.size();
}

QVariant VisitModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_visits.size())
        return QVariant();

    const auto &visit = m_visits.at(index.row());

    if (role == ClientNameRole) {
        return visit.clientName;
    } else if (role == VisitTimeRole) {
        return visit.visitTime;
    }

    return QVariant();
}

QHash<int, QByteArray> VisitModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[ClientNameRole] = "clientName";
    roles[VisitTimeRole] = "visitTime";
    return roles;
}

void VisitModel::addVisit(const QString &clientName, const QString &visitTime) {
    if (clientName.trimmed().isEmpty())
        return;

    beginInsertRows(QModelIndex(), m_visits.size(), m_visits.size());

    QString timeStr = visitTime.isEmpty()
                          ? QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm")
                          : visitTime;

    m_visits.append({clientName, timeStr});
    endInsertRows();

    saveToFile();
}

void VisitModel::removeVisit(int index) {
    if (index < 0 || index >= m_visits.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_visits.removeAt(index);
    endRemoveRows();

    saveToFile();
}

void VisitModel::saveToFile() const {
    QJsonArray jsonArray;
    for (const auto &visit : m_visits) {
        QJsonObject obj;
        obj["clientName"] = visit.clientName;
        obj["visitTime"] = visit.visitTime;
        jsonArray.append(obj);
    }

    QJsonDocument doc(jsonArray);
    QFile file(VISITS_FILE);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
}

void VisitModel::loadFromFile() {
    QFile file(VISITS_FILE);
    if (!file.open(QIODevice::ReadOnly))
        return;

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray())
        return;

    m_visits.clear();
    QJsonArray jsonArray = doc.array();
    for (const auto &val : jsonArray) {
        QJsonObject obj = val.toObject();
        QString name = obj["clientName"].toString();
        QString time = obj["visitTime"].toString();
        if (!name.isEmpty()) {
            m_visits.append({name, time});
        }
    }
}

int VisitModel::getClientVisitCount(const QString &clientName) const {
    int count = 0;
    QString targetName = clientName.trimmed();

    for (const auto &item : m_visits) {
        if (item.clientName.compare(targetName, Qt::CaseInsensitive) == 0) {
            count++;
        }
    }
    return count;
}