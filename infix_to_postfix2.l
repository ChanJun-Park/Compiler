%{
	#include <iostream>
    #include <stack>
    #include <string>
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
[.*]        { return (INVALID); }

%%

stack<char> op_stack;

bool expression(string& str) {
    TOKEN t = yylex();
    switch(t) {
    case ID:
    case NUMBER:
    {
        char * buf = (char*)yytext;
        for (int i=0; i<yyleng; i++) {
            str.push_back(buf[i]);
        }
        str.push_back(' ');
        break;
    }
    case ENTER:
        cout << "error\n";
        while(!op_stack.empty())
            op_stack.pop();
        return false;
    case END_OF_FILE:
        exit(0);
    default:
        cout << "error\n";
        while(!op_stack.empty())
            op_stack.pop();
        do {
            t = yylex();
        } while(t != ENTER && t != END_OF_FILE);
        if (t == END_OF_FILE) exit(0);
        return false;
    }

    bool line_end = false;
    while(!line_end) {
        t = yylex();
        switch(t) {
        case OPERATOR:
        {
            if(!op_stack.empty()) {
                str.push_back(op_stack.top());
                str.push_back(' ');
                op_stack.pop();
            }
            char * buf = (char*)yytext;
            op_stack.push(buf[0]);
            return expression(str);
        }
        case ENTER:
            if(!op_stack.empty()) {
                str.push_back(op_stack.top());
                str.push_back(' ');
                op_stack.pop();
            }
            line_end = true;
            break;
        case END_OF_FILE:
            if(!op_stack.empty()) {
                str.push_back(op_stack.top());
                str.push_back(' ');
                op_stack.pop();
            }
            cout << str << '\n';
            exit(0);
        default:
            cout << "error\n";
            while(!op_stack.empty())
                op_stack.pop();
            do {
                t = yylex();
            } while(t != ENTER && t != END_OF_FILE);
            if (t == END_OF_FILE) exit(0);
            return false;
        }
    }
    return true;
} 

int main() {
    string exp;
    while(true) {
        if(expression(exp)) {
            cout << exp << '\n';
        }
        exp.clear();
    }
	return 0;
}