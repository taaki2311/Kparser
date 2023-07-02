%{
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *error);

int yydebug = 1;

extern FILE *yyin;
%}

%union {char *string;}
%start statements

%token CONFIG
%token CHOICE
%token ENDCHOICE
%token PROMPT
%token DEFAULT
%token DEPENDS

%token <string> VARIABLE
%token <string> TYPE
%token <string> STRING
%token <string> NUMBER
%token <string> HEX_VALUE
%token <string> BOOL
%token <string> TRISTATE

%token <string> HELP

%type <string> value

%%

statement   : choice ENDCHOICE                          { printf("statement create choice\n"); }
            | config                                    { printf("statement create config\n"); }
            ;

statements  : statement                                 { ; }
            | statements statement                      { ; }
            ;

choice      : CHOICE VARIABLE                  { printf("\tcreate choice %s\n", $2); }
            | choice PROMPT STRING             { printf("\tchoice prompt %s\n", $3); }
            | choice DEFAULT VARIABLE          { printf("\tchoice default %s\n", $3); }
            | choice config                    { printf("\tAdding config to choice\n"); }
            | choice HELP                       { printf("\tchoice help %s", $2); }
            ;

config      : CONFIG VARIABLE TYPE value   { printf("\tcreate config %s, %s, %s\n", $2, $3, $4); }
            | config DEPENDS VARIABLE          { printf("\tconfig depends on %s\n", $3); }
            | config DEFAULT value             { printf("\tconfig defaults to %s\n", $3); }
            | config HELP                       { printf("\tconfig help: %s", $2); }
            ;

value       : NUMBER                                    { printf("\tnumber %s\n", $1); }
            | HEX_VALUE                                 { printf("\thex %s\n", $1); }
            | STRING                                    { printf("\tstring %s\n", $1); }
            | BOOL                                      { printf("\tboolean %s\n", $1); }
            | TRISTATE                                  { printf("\ttristate %s\n", $1); }
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

void yyerror(const char *error) {
    fprintf(stderr, "%s\n", error);
}