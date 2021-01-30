%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"bool"|"int"|"float"|"char"|"string" { 
    strcpy(yylval.tip, yytext); 
    return TIP; 
}
"void" { 
    strcpy(yylval.tip, yytext); 
    return VOID; 
}
"START" { return START; }
"END" { return END; }
_[_a-zA-Z][_a-zA-Z0-9]* { 
    strcpy(yylval.nume, yytext); 
    return ID;
}
"constant" { return CONSTANT; }
0|-?[1-9][0-9]* { 
    strcpy(yylval.stringval, yytext);
    return NR_INTREG;
}
-?[0-9]+"."[0-9]+ { 
    strcpy(yylval.stringval, yytext);
    return NR_REAL;
}
"=" { return ASSIGN; }
"["[1-9][0-9]*"]" { 
    char mesaj[100]; 
    strcpy(mesaj, yytext + 1); 
    mesaj[strlen(mesaj) - 1] = 0; // eliminam [ ]
    strcpy(yylval.dim, mesaj); 
    return DIMENSIUNE; 
}
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"for" { return FOR; }
"true" { return TRUE; }
"false" { return FALSE; }
"\""[a-zA-Z]+"\"" { 
    char mesaj[100]; 
    strcpy(mesaj, yytext + 1); 
    mesaj[strlen(mesaj) - 1] = 0; // eliminam ""
    strcpy(yylval.sir, mesaj); 
    return SIR; 
}
"'"."'" {
    char s[3];
    s[0] = yytext[1];
    s[1] = '\0';
    strcpy(yylval.stringval, s);
    return CARACTER;
} 
"<"|">"|"=="|"!="|"<="|">=" { 
    strcpy(yylval.operator_comp, yytext); 
    return COMPARARE; 
}
"Eval" { return EVAL; }
"CONCAT" { return CONCAT_SIR; }
"COMPARE" { return COMPARE_SIR; }
"structure" { return STRUCTURE; }
"return" { return RETURN; }
"define" { return DEFINE; }
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
