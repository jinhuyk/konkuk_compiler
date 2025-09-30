%option noyywrap

%{
#include <stdio.h>
%}

%%

[0-9]+              { printf("NUMBER: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*   { printf("WORD: %s\n", yytext); }
[ \t\n]+            ;   /* 공백/개행 무시 */
[\/][\/].*          { printf("comment: %s\n",yytext);}
[\/][*].*[*][\/]    { printf("comment-long: %s\n",yytext);}
.                   { printf("UNKNOWN: %s\n", yytext); }

%%

int main(void) {
    yylex();
    return 0;
}
