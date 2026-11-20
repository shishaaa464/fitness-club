#ifndef OBSERVER_H
#define OBSERVER_H

#include <QString>
#include <QVector>
#include <algorithm>
#include <QDebug>

class IObserver {
public:
    virtual ~IObserver() = default;
    virtual void update(const QString &message) = 0;
};

class ISubject {
public:
    virtual ~ISubject() = default;
    virtual void attach(IObserver *observer) = 0;
    virtual void detach(IObserver *observer) = 0;
    virtual void notify(const QString &message) = 0;
};

class MembershipNotifier : public ISubject {
private:
    QVector<IObserver*> m_observers;

public:
    void attach(IObserver *observer) override {
        m_observers.append(observer);
    }

    void detach(IObserver *observer) override {
        m_observers.erase(std::remove(m_observers.begin(), m_observers.end(), observer), m_observers.end());
    }

    void notify(const QString &message) override {
        for (IObserver *observer : m_observers) {
            observer->update(message);
        }
    }
};

class ConsoleNotificationLogger : public IObserver {
public:
    void update(const QString &message) override {
        qDebug() << "[УВЕДОМЛЕНИЕ СИСТЕМЫ]:" << message;
    }
};

#endif // OBSERVER_H