#ifndef DECK_H
#define DECK_H

#include <QObject>

#include "card.h"

class Deck : public QObject
{
public:
    Deck();

private:
    QString m_id;
    QString m_name;
    CardList m_cardList;
};

#endif // DECK_H
