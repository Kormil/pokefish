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

    bool parse(QString& outUrlParameters) {
        QStringList parsed;

        if (m_name.length()) {
            parsed << "name:" + m_name;
        }

        if (m_type.length() && m_type != "Any") {
            parsed << "type:" + m_type;
        }

        if (m_subtype.length() && m_subtype != "Any") {
            parsed << "subtype:" + m_subtype;
        }

        outUrlParameters = parsed.join("&");
        return outUrlParameters.length();
    }

    QString m_name;
    QString m_type;
    QString m_subtype;
};

using SearchParametersPtr = std::shared_ptr<SearchParameters>;

#endif // SEARCHPARAMETERS_H
