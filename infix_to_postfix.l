%{
	#include <iostream>
    #include <stack>
    #include <string>
    using namespace std;
	#define ID			1
	#define NUMBER		2
	#define OPERATOR	3
	typedef int TOKEN;
%}

/* regular definition */
delim	[ \t]
ws		{delim}+
letter	[A-Za-z_]
digit	[0-9]
id		{letter}({letter}|{digit})*
number	{digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%

{ws}		{/* no action and no returns */}
{id}		{ return (ID); }
{number}	{ return (NUMBER); }
[+-]		{ return (OPERATOR); }

%%

stack<char> op;

void primary(string& str) {
	TOKEN t = yylex();
	switch(t) {
	case NUMBER:
	case ID:
    {
        char * buf = (char*)yytext;
        for (int i=0; i<yyleng; i++)
            str.push_back(buf[i]);
        str.push_back(' ');
		return;
    }
	default:
		printf("error\n");
		exit(0);
	}
}

void expression(string& str) {
	primary(str);
	TOKEN t = yylex();
	while(t == OPERATOR) {
        if(!op.empty()) {
            str.push_back(op.top());
            str.push_back(' ');
            op.pop();
        }
        char* buf = (char*)yytext;
        op.push(buf[0]);
		primary(str);
		t = yylex();
	}
    str.push_back(op.top());
    op.pop();
}

int main() {
    string pf_str;
	expression(pf_str);
    cout << pf_str << '\n';
	return 0;
}