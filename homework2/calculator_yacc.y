    /*
        calculator_lex.yacc
        작성자 : 12130397 박찬준
        수식 계산기 프로그램 yacc 파트 
    */

%{
#include <stdio.h>
#define YYSTYPE double
FILE *yyin;
FILE *yyout;
%}
%token NUMBER

%left '+' '-'
%left '*' '/'
%right UMINUS
%% 
lines   :   lines expr ';' { fprintf(yyout, "%g\n", $2); } 
        |   lines '\n'
        |
        |   error '\n'          { fprintf(yyout, "Error\n"); yyerror("Reenter previous line"); yyerrok; }
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
int main(int argc, char* argv[]) 
{
    // 프로그램 실행 방식 설명
    if(argc < 2) {
        printf("Invalid command : specify a input file after program's name.\n calculator \"input.txt\" \n ");
        return 1;
    }
    yyin = fopen(argv[1], "r");
    yyout = fopen("output.txt", "w");

    yyparse();

    fclose(yyin); 
    fclose(yyout);
    return 0;
}

