%{ 
/* analisador léxico para uma calculadora */
/* com suporte a definição de variáveis */
#include "parser.h"
%}

%option yylineno
%option noyywrap
%x T

digito	[0-9]
letra_	[a-zA-Z_]
pontdig {digito}*"."?{digito}+
digpont {digito}+"."

numero  {pontdig}|{digpont} 
id		{letra_}({letra_}|{digito})*

%%

[\t ]+		{ ; /* ignora espaço em branco */ }
{numero}    { yylval.num = atof(yytext); return NUM; }

"print"     { return PRINT; }
"pow"       { return POW;   }
"sqrt"      { return SQRT;  }

"if"        { return IF;    }

"=="        { return EQ;    } // equals
">"         { return GT;    } // greater than
"<"         { return LT;    } // less than
">="        { return GTE;   } // greater than or equal
"<="        { return LTE;   } // less than or equal

{id}		{ strcpy(yylval.id, yytext); return ID; }

\"          { BEGIN T; }
<T>[^\"]*   { strcpy(yylval.text, yytext); }
<T>\"       { BEGIN INITIAL; return TEXT; }       

.|\n		{ return yytext[0]; }

%%
