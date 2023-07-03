%{
#include "Kparser.h"
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *error);

int yydebug = 1;

extern FILE *yyin;

char valueType(struct value *value);

%}

%union { char *string; long number; struct value value; }
%start statements

%token CONFIG
%token CHOICE
%token ENDCHOICE
%token PROMPT
%token DEFAULT
%token DEPENDS

%token <string> HELP
%token <string> TYPE
%token <string> VARIABLE

%token <string> T_STRING
%token <number> T_INTEGER
%token <number> T_HEX_VALUE
%token <number> T_BOOL
%token <number> T_TRISTATE

%type <value> value

%%

statement   : choice ENDCHOICE                          { printf("statement create choice\n"); }
            | config                                    { printf("statement create config\n"); }
            ;

statements  : statement                                 { ; }
            | statements statement                      { ; }
            ;

choice  : CHOICE VARIABLE           { printf("\tcreate choice %s\n", $2); }
        | choice PROMPT T_STRING    { printf("\tchoice prompt %s\n", $3); }
        | choice DEFAULT VARIABLE   { printf("\tchoice default %s\n", $3); }
        | choice config             { printf("\tAdding config to choice\n"); }
        | choice HELP               { printf("\tchoice help %s", $2); }
        ;

config  : CONFIG VARIABLE TYPE value   { printf("\tcreate config %s, %s, %c\n", $2, $3, valueType(&$4)); }
        | config DEPENDS VARIABLE      { printf("\tconfig depends on %s\n", $3); }
        | config DEFAULT value         { printf("\tconfig defaults to %c\n", valueType(&$3)); }
        | config HELP                  { printf("\tconfig help: %s", $2); }
        ;

value : T_INTEGER   { $$.type = INTEGER;    $$.number = $1; }
      | T_HEX_VALUE { $$.type = HEX_VALUE;  $$.number = $1; }
      | T_STRING    { $$.type = STRING;     $$.string = $1; }
      | T_BOOL      { $$.type = BOOL;       $$.number = $1; }
      | T_TRISTATE  { $$.type = TRISTATE;   $$.number = $1; }
      ;

%%

int main(void) {
    yyin = fopen("Kconfig", "r");
    if (yyin == NULL)
    {
        yyerror("Kconfig file not found");
        return 1;
    }

    /* Initialize Symbol Table */

    int status = yyparse();

    fclose(yyin);
    return status;
}

char valueType(struct value *value) {
    switch (value->type) {
        case STRING:
            return 'S';
        case INTEGER:
            return 'I';
        case HEX_VALUE:
            return 'H';
        case BOOL:
            return 'B';
        case TRISTATE:
            return 'T';
    }
}

void yyerror(const char *error) {
    fprintf(stderr, "%s\n", error);
}