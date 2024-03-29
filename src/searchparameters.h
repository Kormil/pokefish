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
    SearchParameters(QObject * parent = nullptr) : QObject(parent) {}

    bool parse(QString& outUrlParameters) const {
        QStringList parsed;

        if (m_name.length()) {
            // hack for & chars ( * means any char )
            auto name = m_name;
            name = name.replace("&", "*");

            parsed << "name:" + name;
        }

        parsed << addParameter(m_type, "type");
        parsed << addParameter(m_subtype, "subtype");
        parsed << addParameter(m_ptcgoSeriesCode, "set.ptcgoCode", "set.id");
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

    QString addParameter(QString value, QString name, QString name2) const {
        if (value.length() && value != "Any") {
            return QString("(%1:%2 OR %3:%2)").arg(name).arg(value).arg(name2);
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
