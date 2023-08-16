%{
#include "Kparser.h"
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *error);

int yydebug = 1;

void debug_print(char *string);

%}

%union {
    char *string;
    long number;
    enum ktype type;
    struct kvalue value;
    struct kconfig config;
    struct kchoice choice;
    struct kvariable variable;
    struct krange range;
}
%start statements

%token T_CONFIG
%token T_CHOICE
%token T_DEFAULT
%token T_DEPENDS
%token T_ENDCHOICE
%token T_ENDMENU
%token T_IF
%token T_MENU
%token T_NOT
%token T_PROMPT
%token T_RANGE
%token T_SELECT
%token T_SOURCE

%token <string> T_HELP
%token <type> T_TYPE
%token <type> T_DEF_TYPE
%token <string> T_OPERATOR
%token <string> T_VARIABLE

%token <string> T_STRING
%token <number> T_INTEGER
%token <number> T_HEX_VALUE
%token <number> T_BOOL
%token <number> T_TRISTATE

%type <value> value
%type <value> default
%type <config> config
%type <choice> choice
%type <variable> variable
%type <string> prompt
%type <range> range

%left T_NOT

%%

statement   : menu T_ENDMENU    { ; }
            | variable          { ; }
            ;

statements  : statement             { ; }
            | statements statement  { ; }
            ;

menu        : T_MENU prompt             { ; }
            | menu variable             { ; }
            | menu T_SOURCE T_STRING    { debug_print($3); }
            ;

variable    : choice T_ENDCHOICE    { $$.type = CHOICE; $$.value.choice = $1; }
            | config                { $$.type = CONFIG; $$.value.config = $1; }
            | variable T_VARIABLE   { $$.name = $2; }
            | variable prompt       { $$.prompt = $2; }
            | variable T_HELP       { $$.help = $2; }
            | variable default      { $$.default_value = $2; }
            | variable depends      { ; }
            ;

choice      : T_CHOICE      { ; }
            | choice config { ; }
            ;

config      : T_CONFIG                      { ; }
            | config T_TYPE                 { $$.type = $2; }
            | config T_DEF_TYPE value       { $$.type = $2; $$.value = $3; }
            | config T_DEF_TYPE T_NOT value { $$.type = $2; $$.value = $4; $$.not_flag = true; }
            | config T_SELECT T_VARIABLE    { debug_print("Implment Select"); }
            | config range                  { $$.range = $2; }
            | config T_IF T_VARIABLE        { debug_print("Implement if"); }
            ;

prompt      : T_PROMPT T_STRING { $$ = $2; }
            | T_STRING          { $$ = $1; }
            ;

value       : T_INTEGER   { $$.type = INTEGER;    $$.value.number = $1; }
            | T_HEX_VALUE { $$.type = HEX_VALUE;  $$.value.number = $1; }
            | T_STRING    { $$.type = STRING;     $$.value.string = $1; }
            | T_BOOL      { $$.type = BOOL;       $$.value.number = $1; }
            | T_TRISTATE  { $$.type = TRISTATE;   $$.value.number = $1; }
            | T_VARIABLE  { $$.type = VARIABLE;   $$.value.string = $1; }
            ;

default     : T_DEFAULT value { $$ = $2; }

depends     : T_DEPENDS
            | depends T_VARIABLE
            | T_NOT depends
            | depends operator
            ;

operator    : T_OPERATOR
            | T_NOT operator
            | operator T_NOT
            | operator T_OPERATOR
            ;

range       : T_RANGE value value { $$.lower = $2; $$.upper = $3; }
%%

int main(void) {
    return yyparse();
}

void debug_print(char *string) {
    printf("%*s\n", 120, string);
}

void yyerror(const char *error) {
    fprintf(stderr, "%s\n", error);
}