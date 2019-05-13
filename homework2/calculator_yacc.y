    /*
        calculator_lex.yacc
        작성자 : 12130397 박찬준
        수식 계산기 프로그램 yacc 파트 
    */

%{
#include <stdio.h>
#define YYSTYPE double
%}
%token NUMBER

%left '+' '-'
%left '*' '/'
%right UMINUS
%%
line    :   expr ';''\n'        { printf("%g\n", $1); } 
        ; 
expr    :   expr '+' expr       { $$ = $1 + $3; }
        |   expr '-' expr       { $$ = $1 - $3; }
        |   expr '*' expr       { $$ = $1 * $3; }
        |   expr '/' expr       { $$ = $1 / $3; }
        |   '(' expr ')'        { $$ = $2; }
        |   '-' expr    %prec UMINUS    { $$ = - $2; }
        |   NUMBER
        ;
%%
#include "lex.yy.c"
int main() {
    while(1){
        yyparse();
    }
    
}

