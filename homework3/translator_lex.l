    /*
        translator_lex.l
        작성자 : 12130397 박찬준
        three address code 생성기 lex 파트 
    */
%{
#include <stdio.h>

%}

/* regular definition */
delim	[ \t]
ws		{delim}+
letter	[A-Za-z_]
digit	[0-9]
id		{letter}({letter}|{digit})*
number  {digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%

{ws}		{/* no action and no returns */}
{number}    { sscanf(yytext, "%lf", &floatVal); return NUMBER; }
"float"/" " { return FLOAT; }
"int"/" "   { return INT; }
{id}        { lexeme = string(yytext); return ID; }
\n|.        { return yytext[0]; }

%%
