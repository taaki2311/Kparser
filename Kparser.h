#ifndef KPARSER_H
#define KPARSER_H

#include <stdbool.h>

enum ktype {
    STRING,
    INTEGER,
    HEX_VALUE,
    BOOL,
    TRISTATE,
    VARIABLE
};

struct kvalue {
    enum ktype type;
    union {
        long number;
        char *string;
    } value;
};

struct krange {
    struct kvalue lower;
    struct kvalue upper;
};

struct kconfig {
    enum ktype type;
    struct kvalue value;
    struct krange range;
    bool not_flag;
};

struct kchoice {
    char *default_config;
    struct kconfig *config;
};

struct kvariable {
    char *name;
    char *help;
    char *prompt;
    struct kvalue default_value;

    enum {
        CONFIG,
        CHOICE
    } type;

    union {
        struct kconfig config;
        struct kchoice choice;
    } value;
};

#endif /* KPARSER_H */