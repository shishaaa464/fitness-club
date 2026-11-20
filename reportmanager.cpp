#include "reportmanager.h"
#include <QString>

ReportManager::ReportManager(QObject *parent) : QObject(parent) {}

QString ReportManager::generateReport(int totalClients, int totalVisits, double totalRevenue) {
    QString report;
    report += "=== ОТЧЕТ ФИТНЕС-КЛУБА ===\n";
    report += "• Всего зарегистрированных клиентов: " + QString::number(totalClients) + "\n";
    report += "• Всего посещений зафиксировано: " + QString::number(totalVisits) + "\n";
    report += "• Общая выручка клуба: " + QString::number(totalRevenue, 'f', 2) + " руб.\n";
    report += "============================";

    return report;
}