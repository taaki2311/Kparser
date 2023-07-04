#ifndef KPARSER_H
#define KPARSER_H

enum ktype {
    STRING,
    INTEGER,
    HEX_VALUE,
    BOOL,
    TRISTATE
};

struct kvalue {
    enum ktype type;
    union {
        long number;
        char *string;
    };
};

#endif /* KPARSER_H */