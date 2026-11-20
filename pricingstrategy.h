#ifndef PRICINGSTRATEGY_H
#define PRICINGSTRATEGY_H

#include <QString>

class IPricingStrategy {
public:
    virtual ~IPricingStrategy() = default;
    virtual double calculatePrice(double basePrice) = 0;
    virtual QString getName() const = 0;
};

class StandardPricingStrategy : public IPricingStrategy {
public:
    double calculatePrice(double basePrice) override {
        Q_UNUSED(basePrice);
        return 500.0;
    }
    QString getName() const override {
        return "Разовый";
    }
};

class DiscountPricingStrategy : public IPricingStrategy {
public:
    double calculatePrice(double basePrice) override {
        Q_UNUSED(basePrice);
        return 1500.0;
    }
    QString getName() const override {
        return "Месячный льготный";
    }
};

class PremiumPricingStrategy : public IPricingStrategy {
public:
    double calculatePrice(double basePrice) override {
        Q_UNUSED(basePrice);
        return 2500.0;
    }
    QString getName() const override {
        return "Месячный";
    }
};

#endif // PRICINGSTRATEGY_H