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
integer {digit}+
float   {digit}+(\.{digit}+)(E[+-]?{digit}+)?

%%

{ws}		{/* no action and no returns */}
{integer}   { sscanf(yytext, "%d", &(yylval.intVal)); return INT_NUMBER; }
{float}     { sscanf(yytext, "%lf", &(yylval.floatVal)); return FLOAT_NUMBER; }
"float"/" " { return FLOAT; }
"int"/" "   { return INT; }
{id}        { strcpy(yylval.lexeme, yytext); return ID; }
\n|.        { return yytext[0]; }

%%
