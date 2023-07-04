%{
#include "Kparser.h"
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *error);

extern FILE *yyin;

int yydebug = 1;

void debug_print(char *string);

%}

%union {
    char *string;
    long number;
    enum ktype type;
    struct kvalue value;
    struct kconfig config;
}
%start statements

%token CONFIG
%token CHOICE
%token DEFAULT
%token DEPENDS
%token ENDCHOICE
%token ENDMENU
%token IF
%token MENU
%token NOT
%token PROMPT
%token RANGE
%token SELECT
%token SOURCE

%token <string> HELP
%token <type> TYPE
%token <type> DEF_TYPE
%token <string> OPERATOR
%token <string> VARIABLE

%token <string> T_STRING
%token <number> T_INTEGER
%token <number> T_HEX_VALUE
%token <number> T_BOOL
%token <number> T_TRISTATE

%type <value> value
%type <config> config
%type <string> prompt

%%

statement   : menu ENDMENU      { ; }
            | choice ENDCHOICE  { ; }
            | config            { ; }
            ;

statements  : statement             { ; }
            | statements statement  { ; }
            ;

menu    : MENU T_STRING             { ; }
        | menu choice ENDCHOICE     { ; }
        | menu config               { ; }
        | menu SOURCE T_STRING      { debug_print($3); }
        ;

choice  : CHOICE                    { ; }
        | choice VARIABLE           { debug_print($2); }
        | choice prompt             { debug_print($2); }
        | choice DEFAULT VARIABLE   { debug_print($3); }
        | choice depends            { ; }
        | choice config             { ; }
        | choice HELP               { debug_print($2); }
        ;

config  : CONFIG VARIABLE               { $$.name = $2; debug_print($2); }
        | config TYPE T_STRING          { $$.type = $2; $$.prompt = $3; }
        | config TYPE                   { $$.type = $2; }
        | config prompt                 { $$.prompt = $2; }
        | config DEF_TYPE value         { $$.type = $2; $$.value = $3; }
        | config DEF_TYPE NOT value     { $$.type = $2; $$.value = $4; debug_print("Not"); }
        | config depends                { debug_print("Implement Depends"); }
        | config DEFAULT value          { $$.default_value = $3; }
        | config HELP                   { $$.help = $2; }
        | config SELECT VARIABLE        { debug_print($3); }
        | config range                  { ; }
        | config IF VARIABLE            { debug_print("Implement if"); }
        ;

prompt : PROMPT T_STRING    { $$ = $2; }

value : T_INTEGER           { $$.type = INTEGER;    $$.number = $1; }
      | T_HEX_VALUE         { $$.type = HEX_VALUE;  $$.number = $1; }
      | T_STRING            { $$.type = STRING;     $$.string = $1; }
      | T_BOOL              { $$.type = BOOL;       $$.number = $1; }
      | T_TRISTATE          { $$.type = TRISTATE;   $$.number = $1; }
      | VARIABLE            { $$.type = STRING;     $$.string = $1; debug_print($1); }
      | operator VARIABLE   { $$.type = STRING; debug_print($2); }
      ;

depends : DEPENDS
        | depends VARIABLE
        | depends NOT
        | depends operator
        ;

operator    : OPERATOR
            | operator NOT
            | operator OPERATOR
            ;

range   : RANGE value value { debug_print("Implement Range"); }
%%

int main(void) {
    yyin = fopen("Kconfig", "r");
    if (yyin == NULL)
    {
        yyerror("Kconfig file not found");
        return 1;
    }

    int status = yyparse();

    fclose(yyin);
    return status;
}

void debug_print(char *string) {
    printf("%*s\n", 120, string);
}

void yyerror(const char *error) {
    fprintf(stderr, "%s\n", error);
}