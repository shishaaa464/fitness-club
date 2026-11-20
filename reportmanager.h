#ifndef REPORTMANAGER_H
#define REPORTMANAGER_H

#include <QString>
#include <QObject>

class ReportManager : public QObject {
    Q_OBJECT
public:
    explicit ReportManager(QObject *parent = nullptr);

    Q_INVOKABLE QString generateReport(int totalClients, int totalVisits, double totalRevenue);
};

#endif // REPORTMANAGER_H