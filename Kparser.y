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

%}

%union { char *string; long number; enum ktype type; struct kvalue value; }
%start statements

%token CONFIG
%token CHOICE
%token ENDCHOICE
%token PROMPT
%token DEFAULT
%token DEPENDS

%token <string> HELP
%token <type> TYPE
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
        | choice HELP               { printf("\tchoice help %s\n", $2); }
        ;

config  : CONFIG VARIABLE TYPE value   { printf("\tcreate config %s\n", $2); }
        | config DEPENDS VARIABLE      { printf("\tconfig depends on %s\n", $3); }
        | config DEFAULT value         { printf("\tconfig defaults\n"); }
        | config HELP                  { printf("\tconfig help: %s\n", $2); }
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

    int status = yyparse();

    fclose(yyin);
    return status;
}

void yyerror(const char *error) {
    fprintf(stderr, "%s\n", error);
}