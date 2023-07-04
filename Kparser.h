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

struct kconfig {
    char *name;
    enum ktype type;
    struct kvalue default_value;
    char *help;
    char *prompt;
    struct kvalue value;
};

#endif /* KPARSER_H */