#include "clientlistmodel.h"
#include "datamanager.h"
#include "pricingstrategy.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QDate>
#include <memory>
#include <QFile>
#include <QDir>

ClientListModel::ClientListModel(QObject *parent) : QAbstractTableModel(parent) {
    DataManager dataManager;
    QJsonObject rootObj = dataManager.loadData("fitness_data.json");

    if (rootObj.contains("priceOnce")) {
        m_savedPriceOnce = rootObj["priceOnce"].toDouble(500.0);
    }
    if (rootObj.contains("priceDiscount")) {
        m_savedPriceDiscount = rootObj["priceDiscount"].toDouble(1500.0);
    }
    if (rootObj.contains("priceStandard")) {
        m_savedPriceStandard = rootObj["priceStandard"].toDouble(2500.0);
    }

    if (rootObj.contains("clients") && rootObj["clients"].isArray()) {
        QJsonArray clientsArray = rootObj["clients"].toArray();
        for (const QJsonValue &val : clientsArray) {
            QJsonObject obj = val.toObject();
            QString id = obj["id"].toString();
            QString name = obj["name"].toString();
            QString role = obj["role"].toString();
            QString phone = obj["phone"].toString();
            QString mType = obj["membershipType"].toString("Разовый");
            double price = obj["price"].toDouble(500.0);

            QString regDate = obj["registrationDate"].toString();
            QString expiryDate = obj["expiryDate"].toString();

            QString frozenUntil = obj["frozenUntil"].toString();

            User *user = new User(id, name, role, phone, mType, price, regDate, expiryDate, this);

            user->setFrozenUntil(frozenUntil);

            m_clients.append(user);
        }
    }
}

void ClientListModel::saveClientsToDisk() {
    DataManager dataManager;
    QJsonObject rootObj = dataManager.loadData("fitness_data.json");

    QJsonArray clientsArray;
    for (const User *user : m_clients) {
        QJsonObject obj;
        obj["id"] = user->id();
        obj["name"] = user->name();
        obj["role"] = user->role();
        obj["phone"] = user->phone();
        obj["membershipType"] = user->membershipType();
        obj["price"] = user->price();
        obj["registrationDate"] = user->registrationDate();
        obj["expiryDate"] = user->expiryDate();
        obj["password"] = user->password();
        obj["frozenUntil"] = user->frozenUntil();

        clientsArray.append(obj);
    }

    rootObj["clients"] = clientsArray;

    rootObj["priceOnce"] = m_savedPriceOnce;
    rootObj["priceDiscount"] = m_savedPriceDiscount;
    rootObj["priceStandard"] = m_savedPriceStandard;

    dataManager.saveData(rootObj, "fitness_data.json");
}

void ClientListModel::savePricesToDisk(double pOnce, double pDiscount, double pStandard) {
    m_savedPriceOnce = pOnce;
    m_savedPriceDiscount = pDiscount;
    m_savedPriceStandard = pStandard;
    saveClientsToDisk();
}

double ClientListModel::getSavedPriceOnce() const { return m_savedPriceOnce; }
double ClientListModel::getSavedPriceDiscount() const { return m_savedPriceDiscount; }
double ClientListModel::getSavedPriceStandard() const { return m_savedPriceStandard; }

int ClientListModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;

    int count = 0;
    for (const User *user : m_clients) {
        if (!user) continue;

        bool nameMatches = m_filterText.isEmpty() || user->name().contains(m_filterText, Qt::CaseInsensitive);
        bool statusMatches = true;
        if (m_statusFilter == 1) {
            statusMatches = !user->isExpired();
        } else if (m_statusFilter == 2) {
            statusMatches = user->isExpired();
        }

        if (nameMatches && statusMatches) {
            count++;
        }
    }
    return count;
}

int ClientListModel::columnCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return 3;
}

QVariant ClientListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0)
        return QVariant();

    User *targetUser = nullptr;
    int currentIndex = 0;

    for (User *user : m_clients) {
        if (!user) continue;

        bool nameMatches = m_filterText.isEmpty() || user->name().contains(m_filterText, Qt::CaseInsensitive);
        bool statusMatches = true;
        if (m_statusFilter == 1) {
            statusMatches = !user->isExpired();
        } else if (m_statusFilter == 2) {
            statusMatches = user->isExpired();
        }

        if (nameMatches && statusMatches) {
            if (currentIndex == index.row()) {
                targetUser = user;
                break;
            }
            currentIndex++;
        }
    }

    if (!targetUser) return QVariant();

    if (role == Qt::DisplayRole || role == Qt::UserRole + 1) {
        QString status = "";
        if (targetUser->isFrozen()) {
            status = "Заморожен";
        } else if (targetUser->isExpired()) {
            status = "Истёк";
        } else {
            status = "Активен";
        }

        return QString("%1 | %2 | Тел: %3 | До: %4 [%5]")
            .arg(targetUser->name(), targetUser->membershipType(), targetUser->phone(), targetUser->expiryDate(), status);
    }

    return QVariant();
}

QHash<int, QByteArray> ClientListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Qt::UserRole + 1] = "clientData";
    return roles;
}

void ClientListModel::setFilter(const QString &filterText) {
    beginResetModel();
    m_filterText = filterText.trimmed();
    endResetModel();
}

void ClientListModel::addClient(const QString &id, const QString &name, const QString &role, const QString &phone) {
    QDate currentDate = QDate::currentDate();
    QString regDateStr = currentDate.toString("dd-MM-yyyy");
    QString expiryDateStr = regDateStr;

    beginInsertRows(QModelIndex(), m_clients.size(), m_clients.size());
    User *newUser = new User(id, name, role, phone, "Разовый", 500.0, regDateStr, expiryDateStr, this);
    m_clients.append(newUser);
    endInsertRows();
    saveClientsToDisk();
    emit revenueChanged();
}

void ClientListModel::addClientWithStrategy(const QString &id, const QString &name, const QString &phone, int strategyIndex) {
    if (name.trimmed().isEmpty()) return;

    std::unique_ptr<IPricingStrategy> strategy;
    double basePrice = 0.0;

    if (strategyIndex == 0) {
        strategy = std::make_unique<StandardPricingStrategy>();
    } else if (strategyIndex == 1) {
        strategy = std::make_unique<DiscountPricingStrategy>();
    } else {
        strategy = std::make_unique<PremiumPricingStrategy>();
    }

    double finalPrice = strategy->calculatePrice(basePrice);
    QString typeName = strategy->getName();

    QDate currentDate = QDate::currentDate();
    QString regDateStr = currentDate.toString("dd-MM-yyyy");
    QString expiryDateStr;

    if (strategyIndex == 0) {
        expiryDateStr = regDateStr;
    } else {
        expiryDateStr = currentDate.addDays(30).toString("dd-MM-yyyy");
    }

    beginInsertRows(QModelIndex(), m_clients.size(), m_clients.size());
    User *newUser = new User(id, name, "Клиент", phone, typeName, finalPrice, regDateStr, expiryDateStr, this);
    m_clients.append(newUser);
    endInsertRows();

    saveClientsToDisk();
    emit revenueChanged();
}

void ClientListModel::removeClient(int index) {
    if (index < 0 || index >= m_clients.size()) return;

    beginRemoveRows(QModelIndex(), index, index);
    User *user = m_clients.takeAt(index);
    delete user;
    endRemoveRows();

    saveClientsToDisk();
    emit revenueChanged();
}

bool ClientListModel::clientExists(const QString &name) const {
    QString trimmedName = name.trimmed();
    for (const auto *user : m_clients) {
        if (user && user->name().compare(trimmedName, Qt::CaseInsensitive) == 0) {
            return true;
        }
    }
    return false;
}

double ClientListModel::getTotalRevenue() const {
    double total = 0.0;
    for (const User *user : m_clients) {
        if (user) {
            total += user->price();
        }
    }
    return total;
}

void ClientListModel::setStatusFilter(int statusIndex) {
    beginResetModel();
    m_statusFilter = statusIndex;
    endResetModel();
}

QVariantMap ClientListModel::getClientInfoByName(const QString &name) const {
    QVariantMap info;
    QString targetName = name.trimmed();
    for (const User *user : m_clients) {
        if (user && user->name().compare(targetName, Qt::CaseInsensitive) == 0) {
            info["name"] = user->name();
            info["phone"] = user->phone();
            info["membershipType"] = user->membershipType();
            info["price"] = user->price();
            info["expiryDate"] = user->expiryDate();
            info["password"] = user->password();

            QString status = "";
            if (user->isFrozen()) {
                status = "Заморожен";
            } else if (user->isExpired()) {
                status = "Истёк";
            } else {
                status = "Активен";
            }
            info["status"] = status;

            break;
        }
    }
    return info;
}

void ClientListModel::expireClientMembership(const QString &name) {
    QString targetName = name.trimmed();
    for (User *user : m_clients) {
        if (user && user->name().compare(targetName, Qt::CaseInsensitive) == 0) {
            QString yesterday = QDate::currentDate().addDays(-1).toString("dd-MM-yyyy");
            user->setExpiryDate(yesterday);
            break;
        }
    }
    saveClientsToDisk();
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

void ClientListModel::addClientWithStrategyAndPass(const QString &id, const QString &name, const QString &phone, int strategyIndex, const QString &password) {
    User *user = new User(id, name, "Клиент", phone);
    QDate currentDate = QDate::currentDate();

    if (strategyIndex == 0) {
        user->setMembershipType("Разовый (" + QString::number(m_savedPriceOnce) + " руб.)");
        user->setPrice(m_savedPriceOnce);
        user->setExpiryDate(currentDate.toString("dd-MM-yyyy"));
    } else if (strategyIndex == 1) {
        user->setMembershipType("Месячный льготный (" + QString::number(m_savedPriceDiscount) + " руб.)");
        user->setPrice(m_savedPriceDiscount);
        user->setExpiryDate(currentDate.addDays(30).toString("dd-MM-yyyy"));
    } else {
        user->setMembershipType("Месячный (" + QString::number(m_savedPriceStandard) + " руб.)");
        user->setPrice(m_savedPriceStandard);
        user->setExpiryDate(currentDate.addDays(30).toString("dd-MM-yyyy"));
    }

    user->setRegistrationDate(currentDate.toString("dd-MM-yyyy"));
    user->setPassword(password.isEmpty() ? "123" : password);

    beginInsertRows(QModelIndex(), m_clients.size(), m_clients.size());
    m_clients.append(user);
    endInsertRows();

    saveClientsToDisk();
    emit revenueChanged();
}

bool ClientListModel::validateClientLogin(const QString &name, const QString &password) const {
    QString targetName = name.trimmed();
    for (const User *user : m_clients) {
        if (user && user->name().compare(targetName, Qt::CaseInsensitive) == 0) {
            return user->password() == password;
        }
    }
    return false;
}

QVariantMap ClientListModel::getDetailedClientInfo(const QString &name, QObject *visitModelInstance) const {
    QVariantMap info = getClientInfoByName(name);
    for (const User *user : m_clients) {
        if (user && user->name().compare(name.trimmed(), Qt::CaseInsensitive) == 0) {
            info["password"] = user->password();
            break;
        }
    }
    return info;
}

void ClientListModel::markClientVisit(const QString &name) {
    QString targetName = name.trimmed();
    for (User *user : m_clients) {
        if (user && user->name().compare(targetName, Qt::CaseInsensitive) == 0) {
            if (user->membershipType().contains("Разовый", Qt::CaseInsensitive)) {
                QString yesterday = QDate::currentDate().addDays(-1).toString("dd-MM-yyyy");
                user->setExpiryDate(yesterday);
            }
            break;
        }
    }
    saveClientsToDisk();
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

void ClientListModel::addClientWithCustomPrices(const QString &id, const QString &name, const QString &phone,
                                                int strategyIndex, const QString &password,
                                                double pOnce, double pDiscount, double pStandard) {
    User *user = new User(id, name, "Клиент", phone);
    QDate currentDate = QDate::currentDate();

    m_savedPriceOnce = pOnce;
    m_savedPriceDiscount = pDiscount;
    m_savedPriceStandard = pStandard;

    if (strategyIndex == 0) {
        user->setMembershipType("Разовый (" + QString::number(pOnce) + " руб.)");
        user->setPrice(pOnce);
        user->setExpiryDate(currentDate.toString("dd-MM-yyyy"));
    } else if (strategyIndex == 1) {
        user->setMembershipType("Месячный льготный (" + QString::number(pDiscount) + " руб.)");
        user->setPrice(pDiscount);
        user->setExpiryDate(currentDate.addDays(30).toString("dd-MM-yyyy"));
    } else {
        user->setMembershipType("Месячный (" + QString::number(pStandard) + " руб.)");
        user->setPrice(pStandard);
        user->setExpiryDate(currentDate.addDays(30).toString("dd-MM-yyyy"));
    }

    user->setRegistrationDate(currentDate.toString("dd-MM-yyyy"));
    user->setPassword(password.isEmpty() ? "123" : password);

    beginInsertRows(QModelIndex(), m_clients.size(), m_clients.size());
    m_clients.append(user);
    endInsertRows();

    saveClientsToDisk();
    emit revenueChanged();
}

void ClientListModel::requestFreeze(const QString &name, int days) {
    QString targetName = name.trimmed();
    for (User *user : m_clients) {
        if (user && user->name().compare(targetName, Qt::CaseInsensitive) == 0) {
            QDate currentDate = QDate::currentDate();

            QDate freezeEnd = currentDate.addDays(days);
            user->setFrozenUntil(freezeEnd.toString("dd-MM-yyyy"));

            QDate expiry = QDate::fromString(user->expiryDate(), "dd-MM-yyyy");
            if (expiry.isValid()) {
                QDate newExpiry = expiry.addDays(days);
                user->setExpiryDate(newExpiry.toString("dd-MM-yyyy"));
            }
            break;
        }
    }
    saveClientsToDisk();
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

void ClientListModel::exportData(const QString &filePath) {
    QString targetPath = filePath;
    if (targetPath.startsWith("file:///")) {
        targetPath = targetPath.mid(8);
    } else if (targetPath.startsWith("file://")) {
        targetPath = targetPath.mid(7);
    }

    saveClientsToDisk();

    QFile::copy("fitness_data.json", targetPath);
}

void ClientListModel::importData(const QString &filePath) {
    QString sourcePath = filePath;
    if (sourcePath.startsWith("file:///")) {
        sourcePath = sourcePath.mid(8);
    } else if (sourcePath.startsWith("file://")) {
        sourcePath = sourcePath.mid(7);
    }

    if (QFile::exists("fitness_data.json")) {
        QFile::remove("fitness_data.json");
    }

    if (QFile::copy(sourcePath, "fitness_data.json")) {
        beginResetModel();
        qDeleteAll(m_clients);
        m_clients.clear();

        DataManager dataManager;
        QJsonObject rootObj = dataManager.loadData("fitness_data.json");

        if (rootObj.contains("priceOnce")) m_savedPriceOnce = rootObj["priceOnce"].toDouble(500.0);
        if (rootObj.contains("priceDiscount")) m_savedPriceDiscount = rootObj["priceDiscount"].toDouble(1500.0);
        if (rootObj.contains("priceStandard")) m_savedPriceStandard = rootObj["priceStandard"].toDouble(2500.0);

        if (rootObj.contains("clients") && rootObj["clients"].isArray()) {
            QJsonArray clientsArray = rootObj["clients"].toArray();
            for (const QJsonValue &val : clientsArray) {
                QJsonObject obj = val.toObject();
                User *user = new User(
                    obj["id"].toString(),
                    obj["name"].toString(),
                    obj["role"].toString(),
                    obj["phone"].toString(),
                    obj["membershipType"].toString("Разовый"),
                    obj["price"].toDouble(500.0),
                    obj["registrationDate"].toString(),
                    obj["expiryDate"].toString(),
                    this
                    );
                user->setFrozenUntil(obj["frozenUntil"].toString());
                user->setPassword(obj["password"].toString());
                m_clients.append(user);
            }
        }
        endResetModel();
        emit revenueChanged();
    }
}