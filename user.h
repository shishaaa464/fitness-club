#ifndef USER_H
#define USER_H

#include <QString>
#include <QObject>
#include <QJsonObject>

class User : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString role READ role CONSTANT)
    Q_PROPERTY(QString phone READ phone CONSTANT)
    Q_PROPERTY(QString membershipType READ membershipType CONSTANT)
    Q_PROPERTY(double price READ price CONSTANT)
    Q_PROPERTY(QString registrationDate READ registrationDate CONSTANT)
    Q_PROPERTY(QString expiryDate READ expiryDate CONSTANT)
    Q_PROPERTY(QString password READ password CONSTANT)

public:
    explicit User(QString id, QString name, QString role, QString phone,
                  QString membershipType = "", double price = 0.0,
                  QString regDate = "", QString expiryDate = "", QObject *parent = nullptr);

    explicit User(const QJsonObject &json, QObject *parent = nullptr);

    QString id() const;
    QString name() const;
    QString role() const;
    QString phone() const;
    QString membershipType() const;
    double price() const;
    QString registrationDate() const;
    QString expiryDate() const;
    QString password() const;

    void setExpiryDate(const QString &expiryDate);
    void setPassword(const QString &password);
    void setMembershipType(const QString &membershipType);
    void setPrice(double price);
    void setRegistrationDate(const QString &registrationDate);

    Q_INVOKABLE bool isExpired() const;

    QJsonObject toJson() const;

    QString frozenUntil() const;
    void setFrozenUntil(const QString &dateStr);
    bool isFrozen() const;

private:
    QString m_id;
    QString m_name;
    QString m_role;
    QString m_phone;
    QString m_membershipType;
    double m_price;
    QString m_registrationDate;
    QString m_expiryDate;
    QString m_password;
    QString m_frozenUntil;
};

#endif // USER_H