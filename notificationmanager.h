#ifndef NOTIFICATIONMANAGER_H
#define NOTIFICATIONMANAGER_H

#include <QObject>
#include <QStringList>
#include "clientlistmodel.h"

class NotificationManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList notifications READ notifications NOTIFY notificationsChanged)

public:
    explicit NotificationManager(QObject *parent = nullptr);

    Q_INVOKABLE QStringList notifications() const;
    Q_INVOKABLE void checkExpirations(ClientListModel *clientModel);

signals:
    void notificationsChanged();

private:
    QStringList m_notifications;
};

#endif // NOTIFICATIONMANAGER_H