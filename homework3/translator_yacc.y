    /*
        translator_lex.yacc
        작성자 : 12130397 박찬준
        three address code 생성기 yacc 파트 
    */

%{
#include <stdio.h>
#include <unordered_map>
#include <string>
#define T_INT 0
#define T_FLOAT 1
using namespace std;
FILE *yyin;
FILE *yyout;
int cnt = 0;
unordered_map<string, int> sym_table;

string newTemp() 
{
    string temp = "t";
    temp += to_string(cnt++);
    return temp;
}

%}
%union 
{
    int intVal;
    double floatVal;
    string addr;
    string lexeme;
}
%token NUMBER
%token ID
%token FLOAT
%token INT

%left '+' '-'
%left '*' '/'
%right UMINUS
%% 
prog    :   decls stmts 
        ;
decls   :   decls decl ';'
        |   decls '\n'
        |
        ;
decl    :   FLOAT ID            { auto it = sym_table.find( $<lexeme>2 );
                                  if (it == sym_table.end()) { printf("error!\n"); }
                                  else { sym_table[$<lexeme>2] = T_FLOAT; } }
        |   INT ID              { auto it = sym_table.find( $<lexeme>2 );
                                  if (it == sym_table.end()) { printf("error!\n"); }
                                  else { sym_table[$<lexeme>2] = T_INT; } }
        ;
stmts   :   stmts stmt ';'
        |   stmts '\n'
        |
        ;
stmt    :   ID '=' expr         { auto it = sym_table.find( $<lexeme>1 );
                                  if (it == sym_table.end()) { printf("error!\n"); }
                                  else fprintf(yyout, "%s = %s", ($<lexeme>1).c_str(), ($<addr>3).c_str()); }
        ;
expr    :   expr '+' expr       { $<addr>$ = newTemp();
                                  fprintf(yyout, "%s = %s + %s", ($<addr>$).c_str(), ($<addr>1).c_str(), ($<addr>3).c_str()); }
        |   expr '-' expr       { $<addr>$ = newTemp();
                                  fprintf(yyout, "%s = %s - %s", ($<addr>$).c_str(), ($<addr>1).c_str(), ($<addr>3).c_str()); }
        |   expr '*' expr       { $<addr>$ = newTemp();
                                  fprintf(yyout, "%s = %s * %s", ($<addr>$).c_str(), ($<addr>1).c_str(), ($<addr>3).c_str()); }
        |   expr '/' expr       { $<addr>$ = newTemp();
                                  fprintf(yyout, "%s = %s / %s", ($<addr>$).c_str(), ($<addr>1).c_str(), ($<addr>3).c_str()); }
        |   '(' expr ')'        { $<addr>$ = $<addr>2; }
        |   '-' expr    %prec UMINUS    { $<addr>$ = newTemp();
                                          fprintf(yyout, "%s = -%s", ($<addr>$).c_str(), ($<addr>2).c_str()); }
        |   NUMBER              { $<floatVal>$ = floatVal; 
                                  $<addr>$ = to_string(floatVal); }
        |   ID                  { auto it = sym_table.find( $<lexeme>1 );
                                  if (it == sym_table.end()) { printf("error!\n"); }
                                  else {$<addr>$ = $<lexeme>1; } }
        ;
%%
#include "lex.yy.c"
int main(int argc, char* argv[]) 
{
    // 프로그램 실행 방식 설명
    if(argc < 2) {
        printf("Invalid command : specify a input file after program's name.\n translator \"input.txt\" \n ");
        return 1;
    }
    yyin = fopen(argv[1], "r");
    yyout = fopen("output.txt", "w");

    yyparse();

    fclose(yyin); 
    fclose(yyout);
    return 0;
}

