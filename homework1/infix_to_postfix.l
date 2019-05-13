%{
    /*
        infix_to_postfix.l

        작성자 : 12130397 박찬준

        - 정확한 infix 형식의 수식인지를 판단하기 위해 다음과 같은 구문 문법을
        정의하였다. ':' 앞 쪽 레이블이 Non-terminal이며, 아래에 나열되어 있는 
        것들이 Non-terminal 또는 terminal 이다.
        입력 문법
        Expression:
            Primary
            Expression + Primary
            Expression - Primary

        Primary:
            Number
            -Number
            +Number

        Number:
            floating-point-literal
            id

        - Expression은 전체 수식을 의미하는 Non-terminal이다. Primary이거나
        Primary로 끝난다.
        - Primary는 Number나 +,- 부호와 같이 있는 Number이다. 
        - 부호 표시를 패턴 정의에서 처리하게 되면 1+2 와 같은 수식에서 +를 연산자가 아니라
        2에 대한 양의 부호 표시로 인식하기 때문에, Primary 문법 구조에서 부호를 처리하였다.
        - Number는 부동소수점 숫자이거나, identifier이다.

        - 구문 구조를 파악할 수 있도록 expression과 primary라는 함수를 정의하였다.

        - 올바른 수식 입력은 하나의 라인으로 표현되는 것을 가정하고 줄바꿈(\n)문자를 
        ws 로 표현되는 공백 문자열에서 제외하였다.

        - 각 토큰 아이디를 #define 매크로를 통해 정의하였다.

        - yylex() 함수 호출을 통해서 토큰을 전달 받았다
        - 해당 토큰의 lexeme을 yytext 포인터를 통해 접근하였으며 yytext[0]와 같이 
        문자열 배열처럼 사용하였다. 
        - 리터럴의 경우 값을 계산하지 않고, 문자열 형태 그대로 사용하여 변환된 수식에 저장하였다.

    */
	#include <iostream>
    #include <stack>
    #include <string>
    #include <cstring>
    using namespace std;
	#define ID			1
	#define NUMBER      2
	#define OPERATOR	3
    #define ENTER       4
    #define INVALID     5
    #define END_OF_FILE 6
	typedef int TOKEN;
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
{id}		{ return (ID); }
{number}    { return (NUMBER); }
[+-]		{ return (OPERATOR); }
[\n]        { return (ENTER); }
<<EOF>>     { return (END_OF_FILE); }
.           { return (INVALID); }

%%

/*
    잘못된 토큰이 들어옴을 나타내기 위한 예외 클래스
*/
class TokenError {
public:
    TokenError(string _msg) : msg(_msg) {}
    void printMsg() { cout << msg << '\n'; }
private:
    string msg;
};

/*
    - 스택을 이용해서 연산자를 후위표기법 방식으로 변환한다.
    - 연산자가 +, - 만 존재하기 때문에 연산자의 우선순위를 
    고려하지 않아도 된다. 
    - 연산자가 들어왔을 때, 스택에 연산자가 없으면 연산자를 push, 
    스택에 연산자가 존재하면 해당 연산자를 변환된 수식 뒤 쪽에 
    추가하고 pop한 다음, 들어온 연산자를 스택에 push한다.
    - 입력이 끝나면 스택에 남아있는 연산자를 변환된 수식 뒤 쪽에 
    추가한다.  
*/
stack<char> op_stack;
TOKEN t;

/*
    primary
    입력 : 변환될 후위 표기법 수식을 저장할 string 객체의 참조자
    출력 : 없음
    예외 : 잘못된 구문구조가 있거나, 잘못된 토큰이 들어온 경우 TokenError를 throw
    primary 구문 구조를 찾아서 입력으로 들어온 string 문자열의 뒤쪽에 추가한다
    부호는 리터럴만 가질 수 있다고 가정하여, 부호가 있는 경우 바로 다음 토큰은
    NUMBER 임을 보장하도록 하였다.
*/
void primary(string& str) {
    t = yylex();
    switch(t) {
    case NUMBER:
    case ID:
    {
        for (int i=0; i<yyleng; i++) {
            str.push_back(yytext[i]);
        }
        str.push_back(' ');
        return;
    }
    case OPERATOR:
    {
        str.push_back(yytext[0]);
        t = yylex();
        if(t != NUMBER) TokenError("error");
        for (int i=0; i<yyleng; i++) {
            str.push_back(yytext[i]);
        }
        str.push_back(' ');
        return;
    }
    default:
        throw TokenError("error");
    }
}

/*
    expression
    입력 : 변환될 후위 표기법 수식을 저장할 string 객체의 참조자
    출력 : 없음
    예외 : 잘못된 구문구조가 있거나, 잘못된 토큰이 들어온 경우 TokenError를 throw
    입력으로 들어온 string 객체의 참조자에 infix 수식을 postfix로 변환에 저장
    Expression ->
        Expression + Primary | 
        Expression - Primary
    위와 같이 재귀적으로 derivation 되는 과정을 구현하기 위해 반복문을 통해서
    primary를 계속 호출한다.
*/
void expression(string& str) {
    primary(str);
    t = yylex();

    while(true) {
        switch(t) {
        case OPERATOR:
        {
            if(!op_stack.empty()) {
                str.push_back(op_stack.top());
                str.push_back(' ');
                op_stack.pop();
            }
            op_stack.push(yytext[0]);
            primary(str);
            t = yylex();
            break;
        }
        case ENTER:
            if(!op_stack.empty()) {
                str.push_back(op_stack.top());
                str.push_back(' ');
                op_stack.pop();
            }
            return;
        case END_OF_FILE:
            if(!op_stack.empty()) {
                str.push_back(op_stack.top());
                str.push_back(' ');
                op_stack.pop();
            }
            return;
        default:
            throw TokenError("error");
        }
    }
} 

int main() {
    // 입력으로 들어오는 infix 수식을 postfix로 변환하여 exp string 변수에 저장
    string exp;
    while(true) {
        try {
            expression(exp); 
            cout << exp << '\n';
            exp.clear();
            if (t == END_OF_FILE) return 0;
        }
        catch (TokenError& e) {
            e.printMsg();
            while(!op_stack.empty()) op_stack.pop();
            exp.clear();
            if (t == END_OF_FILE) return 0;
            
            // 잘못된 토큰을 포함한 라인을 모두 무시
            do {
                t = yylex();
            } while(t != ENTER);
        }
    }
	return 0;
}