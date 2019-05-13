    /*
        calculator_lex.l
        작성자 : 12130397 박찬준
        수식 계산기 프로그램 lex 파트 
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
{number}    { sscanf(yytext, "%lf", &yylval); return NUMBER; }
\n|.        { return yytext[0]; }

%%
