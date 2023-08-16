%{
#include "Kparser.h"
#include "y.tab.h"
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *error);

void getHelp(void);
void getText(void);
void getType(void);
void getDefType(void);

void getString(void);
void getInteger(void);
void getHexvalue(void);
void getTristate(bool isTristate);
%}

%%

#.*                                     { ; }
choice                                  { return T_CHOICE; }
config                                  { return T_CONFIG; }
default                                 { return T_DEFAULT; }
"depends on"                            { return T_DEPENDS; }
endchoice                               { return T_ENDCHOICE; }
endmenu                                 { return T_ENDMENU; }
if                                      { return T_IF; }
menu                                    { return T_MENU; }
!                                       { return T_NOT; }
prompt                                  { return T_PROMPT; }
range                                   { return T_RANGE; }
source                                  { return T_SOURCE; }
select                                  { return T_SELECT; }

help\n([ \t]+.*\n)+                     { getHelp(); return T_HELP; }
string|int|hex|bool|tristate            { getType(); return T_TYPE; }
def_bool|def_tristate                   { getDefType(); return T_DEF_TYPE; }
&&                                      { getText(); return T_OPERATOR; }
[0-9_]*[A-Z][A-Z0-9_]+                  { getText(); return T_VARIABLE; }

\".*\"                                  { getString(); return T_STRING; }
[0-9]+                                  { getInteger(); return T_INTEGER; }
[0-9a-fA-F]+                            { getHexvalue(); return T_HEX_VALUE; }
y|n                                     { getTristate(false); return T_BOOL; }
y|n|m                                   { getTristate(true); return T_TRISTATE; }
[ \t\n\r]+                              { ; }
.                                       { ECHO; yyerror("unexpected character"); }

%%

void getHelp(void) {
    yylval.string = malloc(yyleng - 6);
    if (yylval.string == NULL) {
        yyerror("Failed to allocate memory");
    }
    yylval.string = strncpy(yylval.string, yytext + 5, yyleng - 6);
    yylval.string[yyleng - 6] = '\0';
}

void getText(void) {
    yylval.string = malloc(yyleng);
    if (yylval.string == NULL) {
        yyerror("Failed to allocate memory");
    }
    yylval.string = strncpy(yylval.string, yytext, yyleng);
}

void getType(void) {
    if (strcmp("string", yytext) == 0) {
        yylval.type = STRING;
    }
    else if (strcmp("int", yytext) == 0) {
        yylval.type = INTEGER;
    }
    else if (strcmp("hex", yytext) == 0) {
        yylval.type = HEX_VALUE;
    }
    else if (strcmp("bool", yytext) == 0) {
        yylval.type = BOOL;
    }
    else if (strcmp("tristate", yytext) == 0) {
        yylval.type = TRISTATE;
    }
    else {
        yyerror("Invalid Type");
    }
}

void getDefType(void) {
    if (strcmp("def_bool", yytext) == 0) {
        yylval.type = BOOL;
    }
    else if (strcmp("def_tristate", yytext) == 0) {
        yylval.type = TRISTATE;
    }
    else {
        yyerror("Invalid Def_Type");
    }
}

void getString(void) {
    yylval.string = malloc(yyleng - 2);
    if (yylval.string == NULL) {
        yyerror("Failed to allocate memory");
    }
    yylval.string = strncpy(yylval.string, yytext + 1, yyleng - 2);
    yylval.string[yyleng - 2] = '\0';
}

void getInteger(void) {
    yylval.number = strtol(yytext, NULL, 10);
}

void getHexvalue(void) {
    yylval.number = strtol(yytext, NULL, 16);
}

void getTristate(bool isTristate) {
    switch(yytext[0]) {
        case 'n':
            yylval.number = 0;
            break;
        case 'y':
            yylval.number = 1;
            break;
        case 'm':
            if (isTristate) {
                yylval.number = 2;
                break;
            }
            else {
                yyerror("Value is a boolean not a tristate");
            }
            break;
        default:
            yyerror("Tristate that is not y/n/m");
            break;
    }
}

int yywrap(void) { return 1; }