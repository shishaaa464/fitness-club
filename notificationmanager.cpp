#include "notificationmanager.h"
#include <QDate>

NotificationManager::NotificationManager(QObject *parent) : QObject(parent) {}

QStringList NotificationManager::notifications() const {
    return m_notifications;
}

void NotificationManager::checkExpirations(ClientListModel *clientModel) {
    m_notifications.clear();

    if (!clientModel) {
        m_notifications.append("⚠️ Ошибка: Модель клиентов недоступна.");
        emit notificationsChanged();
        return;
    }

    int totalRows = clientModel->rowCount();

    if (totalRows == 0) {
        m_notifications.append("ℹ️ База клиентов пуста.");
        emit notificationsChanged();
        return;
    }

    bool foundExpirations = false;

    for (int i = 0; i < totalRows; ++i) {
        QModelIndex index = clientModel->index(i, 0);
        QString clientInfo = clientModel->data(index, Qt::DisplayRole).toString();

        if (clientInfo.contains("Истёк", Qt::CaseInsensitive) || clientInfo.contains("Разовый", Qt::CaseInsensitive)) {
            QString clientName = clientInfo.split(" | ").value(0, "Неизвестный");

            QString membershipType = clientInfo.split(" | ").value(1, "Абонемент");

            if (clientInfo.contains("Истёк", Qt::CaseInsensitive)) {
                m_notifications.append(QString("⚠️ Внимание: У клиента %1 срок абонемента (%2) ИСТЁК!").arg(clientName, membershipType));
            } else {
                m_notifications.append(QString("⚠️ Внимание: У клиента %1 срок абонемента (%2) истекает!").arg(clientName, membershipType));
            }

            foundExpirations = true;
        }
    }

    if (!foundExpirations) {
        m_notifications.append("✅ Все абонементы активны.");
    }

    emit notificationsChanged();
}