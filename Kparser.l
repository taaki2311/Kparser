%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>

void yyerror(const char *error);

void getString(void);
%}

%%

#.*             { ; }
choice          { return CHOICE; }
config          { return CONFIG; }
default         { return DEFAULT; }
"depends on"    { return DEPENDS; }
endchoice       { return ENDCHOICE; }
prompt          { return PROMPT; }
\n              { return EOL; }
bool|string     { getString(); return TYPE; }
[A-Z_]+         { getString(); return VARIABLE; }
\".*\"          { getString(); return STRING; }
[0-9]+          { getString(); return NUMBER; }
[0-9a-fA-F]+    { getString(); return HEX_VALUE; }
y|n             { getString(); return BOOL; }
y|n|m           { getString(); return TRISTATE; }
[ \t]*          { ; }
.               { ECHO; yyerror("unexpected character"); }

%%

void getString(void) {
    yylval.string = malloc(yyleng);
    if (yylval.string == NULL) {
        yyerror("Failed to allocate memory");
    }
    yylval.string = strncpy(yylval.string, yytext, yyleng);
}

int yywrap(void) { return 1; }