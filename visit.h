#ifndef VISIT_H
#define VISIT_H

#include <QString>
#include <QDateTime>
#include <QObject>

class Visit : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString clientId READ clientId CONSTANT)
    Q_PROPERTY(QDateTime visitTime READ visitTime CONSTANT)

public:
    explicit Visit(QObject *parent = nullptr);
    Visit(QString clientId, QDateTime visitTime, QObject *parent = nullptr);

    QString clientId() const;
    QDateTime visitTime() const;

private:
    QString m_clientId;
    QDateTime m_visitTime;
};

#endif // VISIT_H