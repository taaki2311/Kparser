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
    char *depends;
    struct kvalue default_value;
    char *help;
    struct kvalue value;
};

#endif /* KPARSER_H */