%{
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *error);

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
%token HELP

%token <string> VARIABLE
%token <string> TYPE
%token <string> HELP_TEXT
%token <string> STRING
%token <string> NUMBER
%token <string> HEX_VALUE
%token <string> BOOL
%token <string> TRISTATE

%type <string> value

%%

statement       : create_choice                     {printf("statement create choice\n");}
                | create_config                     {printf("statement create config\n");}
                | statement create_choice           {;}
                | statement create_config           {;}
                ;

create_choice   : CHOICE VARIABLE                   {printf("create choice %s\n", $2);}
                | create_choice PROMPT STRING       {printf("choice prompt %s\n", $3);}
                | create_choice DEFAULT VARIABLE    {printf("choice default %s\n", $3);}
                | create_choice help_text           {printf("choice help\n");}
                | create_choice ENDCHOICE           {printf("end choice\n");}
                ;

create_config   : CONFIG VARIABLE TYPE value        {printf("create config %s, %s, %s\n", $2, $3, $4);}
                | create_config DEPENDS VARIABLE    {printf("config depends on %s\n", $3);}
                | create_config DEFAULT value       {printf("config defaults to %s\n", $3);}
                | create_config help_text           {printf("config help\n");}
                ;

help_text       : HELP HELP_TEXT                    {printf("Help: %s\n", $2);}
                ;

value           : NUMBER                            {printf("number %s\n", $1);}
                | HEX_VALUE                         {printf("hex %s\n", $1);}
                | STRING                            {printf("string %s\n", $1);}
                | BOOL                              {printf("boolean %s\n", $1);}
                | TRISTATE                          {printf("tristate %s\n", $1);}
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