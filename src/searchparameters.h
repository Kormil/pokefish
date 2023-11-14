#ifndef SEARCHPARAMETERS_H
#define SEARCHPARAMETERS_H

#include <memory>

#include <QObject>

class SearchParameters : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name MEMBER m_name)
    Q_PROPERTY(QString type MEMBER m_type)
    Q_PROPERTY(QString subtype MEMBER m_subtype)

public:
    SearchParameters(QObject * parent = nullptr) {}

    bool parse(QString& outUrlParameters) const {
        QStringList parsed;

        if (m_name.length()) {
            parsed << "name:" + m_name;
        }

        parsed << addParameter(m_type, "type");
        parsed << addParameter(m_subtype, "subtype");
        parsed << addParameter(m_ptcgoSeriesCode, "set.ptcgoCode");
        parsed << addParameter(m_cardNumber, "number");

        parsed.removeAll(QString(""));
        outUrlParameters = parsed.join(" ");
        return outUrlParameters.length();
    }

    QString addParameter(QString value, QString name) const {
        if (value.length() && value != "Any") {
            return name + ":" + value;
        }

        return "";
    }

    QString m_name;
    QString m_type;
    QString m_subtype;
    QString m_ptcgoSeriesCode;
    QString m_cardNumber;
};

using SearchParametersPtr = std::shared_ptr<SearchParameters>;

#endif // SEARCHPARAMETERS_H
