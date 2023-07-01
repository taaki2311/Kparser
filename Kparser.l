%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>

void yyerror(const char *error);

void getString(void);

%}

%%

"choice" {return CHOICE;}
"config" {return CONFIG;}
"default" {return DEFAULT;}
"depends on" {return DEPENDS;}
"endchoice" {return ENDCHOICE;}
"help" {return HELP;}
"prompt" {return PROMPT;}

("bool"|"string") {getString(); return TYPE;}
[A-Z_]+ {getString(); return VARIABLE;}
("  ".*\n)+ {getString(); return HELP_TEXT;}
\".*\" {getString(); return STRING;}
[0-9]+ {getString(); return NUMBER;}
[0-9a-fA-F]+ {getString(); return HEX_VALUE;}
("y"|"n") {getString(); return BOOL;}
("y"|"n"|"m") {getString(); return TRISTATE;}

[ \t\s\n\r] ;
. {ECHO; yyerror("unexpected character");}

%%

void getString(void) {
    size_t length = strlen(yytext) + 1;
    yylval.string = malloc(length);
    strncpy(yylval.string, yytext, length);
}

int yywrap(void) { return 1; }