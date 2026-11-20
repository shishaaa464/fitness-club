#ifndef VISITMODEL_H
#define VISITMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QString>

struct VisitRecord {
    QString clientName;
    QString visitTime;
};

class VisitModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum VisitRoles {
        ClientNameRole = Qt::UserRole + 1,
        VisitTimeRole
    };

    explicit VisitModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Метод для добавления визита, доступный из QML
    Q_INVOKABLE void addVisit(const QString &clientName, const QString &visitTime = "");
    Q_INVOKABLE void removeVisit(int index);

    Q_INVOKABLE int getClientVisitCount(const QString &clientName) const;

private:
    QVector<VisitRecord> m_visits;
    void saveToFile() const;
    void loadFromFile();
};

#endif // VISITMODEL_H