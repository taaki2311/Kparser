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
%start statement

%token CONFIG
%token CHOICE
%token ENDCHOICE
%token PROMPT
%token DEFAULT
%token DEPENDS

%token <string> VARIABLE
%token <string> TYPE
%token <string> HELP
%token <string> STRING
%token <string> NUMBER
%token <string> HEX_VALUE
%token <string> BOOL
%token <string> TRISTATE

%type <string> value

%%

statement       : create_choice ENDCHOICE                       { printf("statement create choice\n"); }
                | create_config                                 { printf("statement create config\n"); }
                | statement create_choice ENDCHOICE             { ; }
                | statement create_config                       { ; }
                ;

create_choice   : CHOICE VARIABLE                               { printf("\tcreate choice %s\n", $2); }
                | create_choice PROMPT STRING                   { printf("\tchoice prompt %s\n", $3); }
                | create_choice DEFAULT VARIABLE                { printf("\tchoice default %s\n", $3); }
                | create_choice HELP                            { printf("\tchoice help%s\n", $2); }
                | create_choice create_config                   { printf("\tAdding config to choice\n"); }
                ;

create_config   : CONFIG VARIABLE TYPE value                    { printf("\tcreate config %s, %s, %s\n", $2, $3, $4); }
                | create_config DEPENDS VARIABLE                { printf("\tconfig depends on %s\n", $3); }
                | create_config DEFAULT value                   { printf("\tconfig defaults to %s\n", $3); }
                | create_config HELP                            { printf("\tconfig help %s\n", $2); }
                ;

value           : NUMBER                                        { printf("\tnumber %s\n", $1); }
                | HEX_VALUE                                     { printf("\thex %s\n", $1); }
                | STRING                                        { printf("\tstring %s\n", $1); }
                | BOOL                                          { printf("\tboolean %s\n", $1); }
                | TRISTATE                                      { printf("\ttristate %s\n", $1); }
                ;

%%

int main(void) {
    FILE *input = fopen("Kconfig", "r");
    if (input == NULL)
    {
        yyerror("Kconfig file not found");
        return 1;
    }
    yyin = input;

    /* Initialize Symbol Table */

    return yyparse();
}

void yyerror(const char *error) {
    fprintf(stderr, "%s\n", error);
}