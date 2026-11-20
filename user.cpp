#include "user.h"
#include <QDate>

User::User(QString id, QString name, QString role, QString phone,
           QString membershipType, double price,
           QString regDate, QString expiryDate, QObject *parent)
    : QObject(parent), m_id(id), m_name(name), m_role(role), m_phone(phone),
    m_membershipType(membershipType), m_price(price),
    m_registrationDate(regDate.isEmpty() ? QDate::currentDate().toString("dd-MM-yyyy") : regDate),
    m_expiryDate(expiryDate),
    m_password("123") {

    if (m_expiryDate.isEmpty()) {
        QDate reg = QDate::fromString(m_registrationDate, "dd-MM-yyyy");
        if (m_membershipType.contains("Разовый", Qt::CaseInsensitive)) {
            m_expiryDate = reg.toString("dd-MM-yyyy");
        } else {
            m_expiryDate = reg.addDays(30).toString("dd-MM-yyyy");
        }
    }
}

User::User(const QJsonObject &json, QObject *parent)
    : QObject(parent) {
    m_id = json["id"].toString();
    m_name = json["name"].toString();
    m_role = json["role"].toString();
    m_phone = json["phone"].toString();
    m_membershipType = json["membershipType"].toString();

    m_price = json["price"].toDouble(0.0);

    m_registrationDate = json["registrationDate"].toString("dd-MM-yyyy");
    m_expiryDate = json["expiryDate"].toString("dd-MM-yyyy");
    m_password = json["password"].toString("123");
}

QString User::id() const { return m_id; }
QString User::name() const { return m_name; }
QString User::role() const { return m_role; }
QString User::phone() const { return m_phone; }
QString User::membershipType() const { return m_membershipType; }
double User::price() const { return m_price; }
QString User::registrationDate() const { return m_registrationDate; }
QString User::expiryDate() const { return m_expiryDate; }
QString User::password() const { return m_password; }

bool User::isExpired() const {
    QDate expiry = QDate::fromString(m_expiryDate, "dd-MM-yyyy");
    if (!expiry.isValid()) return false;

    return QDate::currentDate() > expiry;
}
void User::setExpiryDate(const QString &expiryDate) { m_expiryDate = expiryDate; }
void User::setPassword(const QString &password) { m_password = password; }
void User::setMembershipType(const QString &type) { m_membershipType = type; }
void User::setPrice(double price) { m_price = price; }
void User::setRegistrationDate(const QString &regDate) { m_registrationDate = regDate; }

QJsonObject User::toJson() const {
    QJsonObject json;
    json["id"] = m_id;
    json["name"] = m_name;
    json["role"] = m_role;
    json["phone"] = m_phone;
    json["membershipType"] = m_membershipType;
    json["price"] = m_price;
    json["registrationDate"] = m_registrationDate;
    json["expiryDate"] = m_expiryDate;
    json["password"] = m_password;
    return json;
}

QString User::frozenUntil() const { return m_frozenUntil; }
void User::setFrozenUntil(const QString &dateStr) { m_frozenUntil = dateStr; }

bool User::isFrozen() const {
    if (m_frozenUntil.isEmpty()) return false;
    QDate freezeDate = QDate::fromString(m_frozenUntil, "dd-MM-yyyy");
    return freezeDate.isValid() && QDate::currentDate() <= freezeDate;
}