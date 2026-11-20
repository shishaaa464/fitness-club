#ifndef MEMBERSHIP_H
#define MEMBERSHIP_H

#include <QString>
#include <QDate>
#include <QObject>
#include "pricingstrategy.h"

class Membership : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QDate startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QDate endDate READ endDate WRITE setEndDate NOTIFY endDateChanged)
    Q_PROPERTY(double price READ price WRITE setPrice NOTIFY priceChanged)
    Q_PROPERTY(bool isActive READ isActive WRITE setIsActive NOTIFY isActiveChanged)

public:
    Q_INVOKABLE explicit Membership(QObject *parent = nullptr);

    Membership(QString type, QDate startDate, QDate endDate, double price, bool isActive, QObject *parent = nullptr);

    QString type() const;
    void setType(const QString &type);

    QDate startDate() const;
    void setStartDate(const QDate &date);

    QDate endDate() const;
    void setEndDate(const QDate &date);

    double price() const;
    void setPrice(double price);

    bool isActive() const;
    void setIsActive(bool active);

    Q_INVOKABLE void applyPricingStrategy(IPricingStrategy *strategy, double basePrice);

signals:
    void typeChanged();
    void startDateChanged();
    void endDateChanged();
    void priceChanged();
    void isActiveChanged();

private:
    QString m_type;
    QDate m_startDate;
    QDate m_endDate;
    double m_price;
    bool m_isActive;
};

#endif // MEMBERSHIP_H