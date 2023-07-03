#ifndef KPARSER_H
#define KPARSER_H

struct value {
    enum {
        STRING,
        INTEGER,
        HEX_VALUE,
        BOOL,
        TRISTATE
    } type;

    union {
        long number;
        char *string;
    };
};

#endif /* KPARSER_H */