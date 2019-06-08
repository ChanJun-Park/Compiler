    /*
        translator_lex.yacc
        작성자 : 12130397 박찬준
        three address code 생성기 yacc 파트 
    */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#define T_INT 0
#define T_FLOAT 1
FILE *yyin;
FILE *yyout;
int cnt = 0;

int yylex();

// hash table
#define MAX_KEY 64
#define MAX_TABLE 4096
 
typedef struct
{
    char key[MAX_KEY + 1];
    int data;
}Hash;
Hash tb[MAX_TABLE];
 
unsigned long hash(const char *str)
{
    unsigned long hash = 5381;
    int c;
 
    while (c = *str++)
    {
        hash = (((hash << 5) + hash) + c) % MAX_TABLE;
    }
 
    return hash % MAX_TABLE;
}
 
int find(const char *key, int *data)
{
    unsigned long h = hash(key);
    int cnt = MAX_TABLE;
 
    while (tb[h].key[0] != 0 && cnt--)
    {
        if (strcmp(tb[h].key, key) == 0)
        {
            *data = tb[h].data;
            return 1;
        }
        h = (h + 1) % MAX_TABLE;
    }
    return 0;
}
 
int add(const char *key, int data)
{
    unsigned long h = hash(key);
 
    while (tb[h].key[0] != 0)
    {
        if (strcmp(tb[h].key, key) == 0)
        {
            return 0;
        }
 
        h = (h + 1) % MAX_TABLE;
    }
    strcpy(tb[h].key, key);
    tb[h].data = data;
    return 1;
}

// addr attribute에 새로운 임시 변수 문자열을 할당해주는 함수
void newTemp(char* addr) 
{
    addr[0] = 't';
    sprintf(&addr[1], "%d", cnt++);
}

// 프로그램 종료시 열려있는 파일들을 처리해주고 종료하는 함수
void exit_translation(int exit_code)
{
    fclose(yyin); 
    fclose(yyout);
    exit(exit_code);
}

%}
%union 
{
    int intVal;
    double floatVal;
    char addr[20];
    char lexeme[100];
}
%token INT_NUMBER
%token FLOAT_NUMBER
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
decl    :   FLOAT ID            { if (!add($<lexeme>2, T_FLOAT)) { 
                                    fprintf(yyout, "Error!\n%s is already declared\n", $<lexeme>2);
                                    exit_translation(1);
                                  }}
        |   INT ID              { if (!add($<lexeme>2, T_INT)) { 
                                    fprintf(yyout, "Error!\n%s is already declared\n", $<lexeme>2);
                                    exit_translation(1);
                                  }}
        ;
stmts   :   stmts stmt ';'
        |   stmts '\n'
        |
        ;
stmt    :   ID '=' expr         { int type; 
                                  if (!find($<lexeme>1, &type)) { 
                                    fprintf(yyout, "Error!\n%s is unknown id\n", $<lexeme>1);
                                    exit_translation(1);
                                  }
                                  else { 
                                    fprintf(yyout, "%s = %s\n", $<lexeme>1, $<addr>3); 
                                  }}
        ;
expr    :   expr '+' expr       { newTemp($<addr>$); fprintf(yyout, "%s = %s + %s\n", $<addr>$, $<addr>1, $<addr>3);  }
        |   expr '-' expr       { newTemp($<addr>$); fprintf(yyout, "%s = %s - %s\n", $<addr>$, $<addr>1, $<addr>3);  }
        |   expr '*' expr       { newTemp($<addr>$); fprintf(yyout, "%s = %s * %s\n", $<addr>$, $<addr>1, $<addr>3);  }
        |   expr '/' expr       { newTemp($<addr>$); fprintf(yyout, "%s = %s / %s\n", $<addr>$, $<addr>1, $<addr>3);  }
        |   '(' expr ')'        { strcpy($<addr>$, $<addr>2); }
        |   '-' expr    %prec UMINUS   { newTemp($<addr>$); fprintf(yyout, "%s = -%s\n", $<addr>$, $<addr>2); }
        |   INT_NUMBER          { sprintf($<addr>$, "%d", $<intVal>1); }
        |   FLOAT_NUMBER        { sprintf($<addr>$, "%E", $<floatVal>1); }
        |   ID                  { int type; 
                                  if (!find($<lexeme>1, &type)) { 
                                    fprintf(yyout, "Error!\n%s is unknown id\n", $<lexeme>1);
                                    exit_translation(1);
                                  }
                                  else { 
                                    strcpy($<addr>$, $<lexeme>1);
                                  }}
        ;
%%
#include "lex.yy.c"
int main(int argc, char* argv[]) 
{
    // 프로그램 실행 방식 설명
    if(argc < 2) {
        printf("Invalid command : specify a input file after program's name.\n ex) translator \"input.txt\" \n ");
        return 1;
    }
    memset(tb, 0, sizeof(tb));
    yyin = fopen(argv[1], "r");
    yyout = fopen("output.txt", "w");

    yyparse();

    exit_translation(0);
    return 0;
}

