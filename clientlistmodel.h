#ifndef CLIENTLISTMODEL_H
#define CLIENTLISTMODEL_H

#include <QAbstractTableModel>
#include <QList>
#include <QString>
#include <QVariantMap>
#include "user.h"

class ClientListModel : public QAbstractTableModel {
    Q_OBJECT
    Q_PROPERTY(double totalRevenue READ getTotalRevenue NOTIFY revenueChanged)

    Q_PROPERTY(double savedPriceOnce READ getSavedPriceOnce CONSTANT)
    Q_PROPERTY(double savedPriceDiscount READ getSavedPriceDiscount CONSTANT)
    Q_PROPERTY(double savedPriceStandard READ getSavedPriceStandard CONSTANT)

public:
    explicit ClientListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setFilter(const QString &filterText);
    Q_INVOKABLE void setStatusFilter(int statusIndex);
    Q_INVOKABLE void addClient(const QString &id, const QString &name, const QString &role, const QString &phone);
    Q_INVOKABLE void addClientWithStrategy(const QString &id, const QString &name, const QString &phone, int strategyIndex);
    Q_INVOKABLE void removeClient(int index);
    Q_INVOKABLE bool clientExists(const QString &name) const;
    Q_INVOKABLE double getTotalRevenue() const;

    Q_INVOKABLE QVariantMap getClientInfoByName(const QString &name) const;
    Q_INVOKABLE void expireClientMembership(const QString &name);

    void saveClientsToDisk();

    Q_INVOKABLE void savePricesToDisk(double pOnce, double pDiscount, double pStandard);
    double getSavedPriceOnce() const;
    double getSavedPriceDiscount() const;
    double getSavedPriceStandard() const;

    Q_INVOKABLE void addClientWithStrategyAndPass(const QString &id, const QString &name, const QString &phone, int strategyIndex, const QString &password);
    Q_INVOKABLE bool validateClientLogin(const QString &name, const QString &password) const;
    Q_INVOKABLE QVariantMap getDetailedClientInfo(const QString &name, QObject *visitModelInstance) const;
    Q_INVOKABLE void markClientVisit(const QString &name);

    Q_INVOKABLE void addClientWithCustomPrices(const QString &id, const QString &name, const QString &phone,
                                               int strategyIndex, const QString &password,
                                               double pOnce, double pDiscount, double pStandard);

    Q_INVOKABLE void requestFreeze(const QString &name, int days);

    Q_INVOKABLE void exportData(const QString &filePath);
    Q_INVOKABLE void importData(const QString &filePath);

signals:
    void revenueChanged();

private:
    QList<User*> m_clients;
    QString m_filterText;
    int m_statusFilter = 0;

    double m_savedPriceOnce = 500.0;
    double m_savedPriceDiscount = 1500.0;
    double m_savedPriceStandard = 2500.0;
};

#endif // CLIENTLISTMODEL_H