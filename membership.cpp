#include "membership.h"

Membership::Membership(QObject *parent)
    : QObject(parent), m_type("Стандартный"), m_startDate(QDate::currentDate()),
    m_endDate(QDate::currentDate().addMonths(1)), m_price(1500.0), m_isActive(true) {}

Membership::Membership(QString type, QDate startDate, QDate endDate, double price, bool isActive, QObject *parent)
    : QObject(parent), m_type(type), m_startDate(startDate), m_endDate(endDate), m_price(price), m_isActive(isActive) {}

QString Membership::type() const { return m_type; }
void Membership::setType(const QString &type) {
    if (m_type != type) {
        m_type = type;
        emit typeChanged();
    }
}

QDate Membership::startDate() const { return m_startDate; }
void Membership::setStartDate(const QDate &date) {
    if (m_startDate != date) {
        m_startDate = date;
        emit startDateChanged();
    }
}

QDate Membership::endDate() const { return m_endDate; }
void Membership::setEndDate(const QDate &date) {
    if (m_endDate != date) {
        m_endDate = date;
        emit endDateChanged();
        bool active = QDate::currentDate() <= m_endDate;
        setIsActive(active);
    }
}

double Membership::price() const { return m_price; }
void Membership::setPrice(double price) {
    if (qAbs(m_price - price) > 0.001) {
        m_price = price;
        emit priceChanged();
    }
}

bool Membership::isActive() const { return m_isActive; }
void Membership::setIsActive(bool active) {
    if (m_isActive != active) {
        m_isActive = active;
        emit isActiveChanged();
    }
}

void Membership::applyPricingStrategy(IPricingStrategy *strategy, double basePrice) {
    if (!strategy) return;

    double calculatedPrice = strategy->calculatePrice(basePrice);
    QString strategyName = strategy->getName();

    setPrice(calculatedPrice);
    setType(strategyName);
}