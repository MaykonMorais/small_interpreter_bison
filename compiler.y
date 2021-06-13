%{
#include <iostream>
#include <string>
#include <unordered_map>
#include <math.h>
#include <cstring>
#include <sstream>


using std::string;
using std::unordered_map;
using std::cout;

int yylex(void);
int yyparse(void);
void yyerror(const char *);

unordered_map<string,double> variables;
%}

%union {
	double num;
	char id[16];
	char text[255];
	char print[255];
}

%token <id> ID
%token <num> NUM
%token <print> PRINT
%token <text> TEXT
%token <if> IF
%token <pow> POW
%token <sqrt> SQRT
%token EQ
%token GT LT GTE LTE

%type <num> expr
%type <text> args
%type <text> term

%left EQ GT LT GTE LTE
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%

math: math calc '\n'
	| calc '\n'
	;

calc: ID '=' expr 			        				{ variables[$1] = $3; 					} 	
	| expr '\n'				        				{ cout << "= " << $1 << "\n";   		}
	| PRINT '(' args ')' '\n'           				{ cout << $3 << "\n"; 					}
	| IF '(' expr ')' PRINT '(' args ')' '\n'   	{ if($3) { cout << $7 << "\n";  }	}
	| IF '(' expr ')' ID '=' expr          		    { if($3) { variables[$5] = $7;  }	}
	| '\n'
	; 

args: term ',' args { 
		std::stringstream ss;
		ss << $1 << $3;
		strcpy($$, ss.str().c_str());
 	}
	| term { strcpy($$, $1); }

	;

term: TEXT { strcpy($$, $1); }
	| expr { 
		std::stringstream ss;
		ss << $1;
		strcpy($$, ss.str().c_str()); 
	}
	; 

expr: expr '+' expr					{ $$ = $1 + $3;  }
	| expr '-' expr   				{ $$ = $1 - $3;  }
	| expr EQ expr                  { $$ = $1 == $3; }
	| expr GT expr         		    { $$ = $1 > $3;  }
	| expr LT expr                  { $$ = $1 < $3;  }
	| expr GTE expr                 { $$ = $1 >= $3; }
	| expr LTE expr                 { $$ = $1 <= $3; }
	| expr '*' expr					{ $$ = $1 * $3;  }
	| POW '(' expr ',' expr ')'     { $$ = pow($3, $5); }
	| SQRT '(' expr ')'             { $$ = sqrt($3); }
	| expr '/' expr			
	{ 
		if ($3 == 0)
			yyerror("division by zero");
		else
			$$ = $1 / $3; 
	}
	| '(' expr ')'			{ $$ = $2; }
	| '-' expr %prec UMINUS { $$ = - $2; }
	| ID					{ $$ = variables[$1]; }
	| NUM
	;

%%

extern FILE * yyin;  

int main(int argc, char ** argv)
{
	/* se foi passado um nome de arquivo */
	if (argc > 1)
	{
		FILE * file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}
		
		/* entrada ajustada para ler do arquivo */
		yyin = file;
	}

	yyparse();
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   

	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "Erro (" << s << "): símbolo \"" << yytext << "\" (linha " << yylineno << ")\n";
}
