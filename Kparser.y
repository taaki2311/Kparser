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
%token EOL

%token <string> VARIABLE
%token <string> TYPE
%token <string> STRING
%token <string> NUMBER
%token <string> HEX_VALUE
%token <string> BOOL
%token <string> TRISTATE

%type <string> value

%%

statement   : choice ENDCHOICE                          { printf("statement create choice\n"); }
            | config                                    { printf("statement create config\n"); }
            | endofline                                 { ; }
            ;

statements  : statement                                 { ; }
            | statements statement                      { ; }
            ;

choice      : CHOICE VARIABLE endofline                 { printf("\tcreate choice %s\n", $2); }
            | choice PROMPT STRING endofline            { printf("\tchoice prompt %s\n", $3); }
            | choice DEFAULT VARIABLE endofline         { printf("\tchoice default %s\n", $3); }
            | choice config                             { printf("\tAdding config to choice\n"); }
            ;

config      : CONFIG VARIABLE EOL TYPE value endofline  { printf("\tcreate config %s, %s, %s\n", $2, $4, $5); }
            | config DEPENDS VARIABLE endofline         { printf("\tconfig depends on %s\n", $3); }
            | config DEFAULT value endofline            { printf("\tconfig defaults to %s\n", $3); }
            ;

value       : NUMBER                                    { printf("\tnumber %s\n", $1); }
            | HEX_VALUE                                 { printf("\thex %s\n", $1); }
            | STRING                                    { printf("\tstring %s\n", $1); }
            | BOOL                                      { printf("\tboolean %s\n", $1); }
            | TRISTATE                                  { printf("\ttristate %s\n", $1); }
            ;

endofline   : EOL                                       { ; }
            | YYEOF                                     { ; }
            | endofline EOL                             { ; }
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