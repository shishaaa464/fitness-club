#include "visit.h"

Visit::Visit(QObject *parent) : QObject(parent) {}

Visit::Visit(QString clientId, QDateTime visitTime, QObject *parent)
    : QObject(parent), m_clientId(clientId), m_visitTime(visitTime) {}

QString Visit::clientId() const { return m_clientId; }
QDateTime Visit::visitTime() const { return m_visitTime; }