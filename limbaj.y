%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;


char *ftoa(float f, int *s);
void printTable();
void addVar(int c, int init, char tip[10], char id[100], char scop[20], char valoare[100]);
void addVector(int c, int init, char tip[10], char id[100], char scop[20], char dim[10]);
void addFunc(int def, char tip[10], char id[100], char scop[100]);
int funcExista(char id[100], char scop[100]); // returneaza indicele functiei
int funcDefinita(char id[100], char scop[100]);
void eroare(char s[1000]);
int varExista(char id[100], char scop[100]); 
int varInitializat(char id[100], char scop[100]); 
int varConstant(char id[100], char scop[100]); 

struct variable {
     int constant;
     int initializat;
     char id[100]; 	// nume variabila
     char tip[10]; 	// (bool, char, int, float, string)
     char scop[20]; // (global, local, function, structure)
     int dim_cur;
     int dimensiune;
     char valoare[100][100]; // vector de valori pt array
};

struct parametru{
     char id[100];
     char tip[100];
     int dimensiune;
     int constant;
};

struct function {
     int definita; // daca a fost scrisa definitia functiei
     char id[100];  // nume functie
     char tip[100]; // (void, bool, char, int, float, string)
     char scop[100]; // global structure
     int nrParam;
     struct parametru param[100];
     char return_[100];
};

struct variable var[1000];
int nrVar = 0;
struct function func[100];
int nrFunc = 0;
char scop[100][20];
int nrScop = 0;
int rez[100];
int nrRez = 0;

char * ftoa(float fl, int * s){
    static char ret[17];
    char * cp = ret;
    unsigned long l, k;
    if(fl < 0) {
        *cp++ = '-';
        fl = -fl;
    }
    l = (unsigned long)fl; fl -= (float)l;
    k = (unsigned long)(fl * 1e6);
    sprintf(cp, "%lu.%6.6lu", l, k);
    return ret;
}

void printTable(){
     FILE* f = fopen("symbol_table.txt", "w");
     fprintf(f, "Variabile:\n");
     for(int i = 0; i < nrVar; ++i)
     {
         
          char mesaj[1024];
          bzero(mesaj, 1023);
          sprintf(mesaj, "TIP: %s NUME: %s SCOP: %s CONSTANT: %s INITIALIZAT: %s ARRAY: %s ",
          var[i].tip, var[i].id, var[i].scop, var[i].constant == 0 ? "nu" : "da", var[i].initializat == 0 ? "nu" : "da", var[i].dimensiune == 1 ? "nu" : "da");
          char val[1024];
          bzero(val, 1023);
          if(var[i].dimensiune == 1)
          	sprintf(val, "VALOARE: %s\n", var[i].valoare[0]);
          else
          {
          	sprintf(val, "DIMENSIUNE: %d VALORI: [", var[i].dimensiune);
          	for(int j = 0; j < var[i].dimensiune - 1; ++j)
          	{
          		strcat(val, var[i].valoare[j]);
          		strcat(val, ", ");
          	}
          	strcat(val, var[i].valoare[var[i].dimensiune - 1]);
          	strcat(val, "].\n");
          }
          strcat(mesaj, val);
          fprintf(f, "%s", mesaj);
     }
     
     fprintf(f, "\n\nFunctii:\n");
     for(int i = 0; i < nrFunc; ++i)
     {
          //printf("%d", func[i].definita);
          char mesaj[1024];
          bzero(mesaj, 1023);
     	  sprintf(mesaj, "%sTIP: %s NUME: %s APARTINE: %s NUMAR PARAMETRI: %d", 
            func[i].definita == 1 ? "DEFINITA " : "NEDEFINITA ", func[i].tip, func[i].id, func[i].scop, func[i].nrParam);
     	  fprintf(f, "%s", mesaj);
     	  
     	  
     	  bzero(mesaj, 1023);
            if(func[i].nrParam > 0)
     	     sprintf(mesaj, " PARAMETRI: ");
     	  for(int j = 0; j < func[i].nrParam; ++j)
     	  {
     	     char s[1024];
               bzero(s, 1023);
               sprintf(s, "%s%s %s", 
               func[i].param[j].constant == 1 ? "constant " : "", func[i].param[j].tip, func[i].param[j].id);
               if(func[i].param[j].dimensiune > 1)
               {
                    char s2[1024];
                    bzero(s2, 1023);
                    sprintf(s2, "[%d]", func[i].param[j].dimensiune);
                    strcat(s, s2);
               }
	       strcat(mesaj, s);
	       if(j < func[i].nrParam - 1)
	            strcat(mesaj, ", ");     
     	  }
            if(strcmp(func[i].tip, "void") != 0 && func[i].definita == 1)
            {
                 strcat(mesaj, " RETURN: ");
                 strcat(mesaj, func[i].return_);
                 //printf("%s", func[i].return_);
            }
     	  fprintf(f, "%s.\n", mesaj);
     }
     fclose(f);
}

void addVar(int c, int init, char tip[10], char id[100], char scop[20], char valoare[100]){
     var[nrVar].constant = c;
     var[nrVar].initializat = init;
     strcpy(var[nrVar].id, id);
     strcpy(var[nrVar].tip, tip);
     strcpy(var[nrVar].scop, scop);
     var[nrVar].dimensiune = 1;
     strcpy(var[nrVar].valoare[0], valoare);
     nrVar++;
}

void addVector(int c, int init, char tip[10], char id[100], char scop[20], char dim[10]){
     
     var[nrVar].constant = c;
     var[nrVar].initializat = 1;
     strcpy(var[nrVar].id, id);
     strcpy(var[nrVar].tip, tip);
     strcpy(var[nrVar].scop, scop);
     var[nrVar].dimensiune = atoi(dim);
     for(int i = 0; i < atoi(dim); ++i)
          strcpy(var[nrVar].valoare[i], "");
     var[nrVar].dim_cur = 0;
     nrVar++;
}

void addFunc(int def, char tip[10], char id[100], char scop[100]){
     func[nrFunc].definita = def;
     strcpy(func[nrFunc].tip, tip);
     strcpy(func[nrFunc].id, id);
     strcpy(func[nrFunc].scop, scop);
     //printf("AICI)");
     nrFunc++;
}

int funcExista(char id[100], char scop[100]){
     if(strcmp(scop, "structure") == 0){
          for(int i = 0; i < nrFunc; ++i)
               if(strcmp(func[i].scop, scop) == 0)
                    if(strcmp(func[i].id, id) == 0)
                         return i;
          return -1;
     }
     for(int i = 0; i < nrFunc; ++i)
          if(strcmp(func[i].scop, scop) == 0 || strcmp(func[i].scop, "global") == 0)
               if(strcmp(func[i].id, id) == 0)
                    return i;
     return -1;
}
int funcExista_siGlobal(char id[100], char scop[100]){
     for(int i = 0; i < nrFunc; ++i)
          if(strcmp(func[i].scop, scop) == 0)
               if(strcmp(func[i].id, id) == 0)
                    return i;
     if(strcmp(scop, "global") != 0)
          for(int i = 0; i < nrFunc; ++i)
               if(strcmp(func[i].scop, "global") == 0)
                    if(strcmp(func[i].id, id) == 0)
                         return i;
     return -1;
}

int funcDefinita(char id[100], char scop[100]){
     for(int i = 0; i < nrFunc; ++i)
     	if(strcmp(func[i].id, id) == 0)
               if(strcmp(func[i].scop, scop) == 0)
                    if(func[i].definita == 1)
                         return 1;
                    else
                         return 0;
}
int funcDefinita_siGlobal(char id[100], char scop[100]){
     for(int i = 0; i < nrFunc; ++i)
     	if(strcmp(func[i].id, id) == 0)
               if(strcmp(func[i].scop, scop) == 0)
                    if(func[i].definita == 1)
                         return 1;
                    else
                         return 0;
     if(strcmp(scop, "global") != 0)
          for(int i = 0; i < nrFunc; ++i)
               if(strcmp(func[i].id, id) == 0)
                    if(strcmp(func[i].scop, "global") == 0)
                         if(func[i].definita == 1)
                              return 1;
                         else
                              return 0;
}

void eroare(char s[1000]){
     printf("Linia: %d --> Eroare: %s.\n", yylineno, s);
     exit(0);
}

int varExista(char id[100], char scop[100]){
     for(int i = 0; i < nrVar; ++i)
          if(strcmp(var[i].scop, scop) == 0)
               if(strcmp(var[i].id, id) == 0)
                    return i;
     return -1;
}
int varExista_siGlobal(char id[100], char scop[100]){
     for(int i = 0; i < nrVar; ++i)
          if(strcmp(var[i].scop, scop) == 0)
               if(strcmp(var[i].id, id) == 0)
                    return i;
     if(strcmp(scop, "global") != 0)
          for(int i = 0; i < nrVar; ++i)
               if(strcmp(var[i].scop, "global") == 0)
                    if(strcmp(var[i].id, id) == 0)
                         return i;
     return -1;
}

int varInitializat(char id[100], char scop[100]){
     for(int i = 0; i < nrVar; ++i)
     	if(strcmp(var[i].id, id) == 0)
               if(strcmp(var[i].scop, scop) == 0)
                    if(var[i].initializat == 1)
                         return 1;
                    else
                         return 0;
}
int varInitializat_siGlobal(char id[100], char scop[100]){
     for(int i = 0; i < nrVar; ++i)
     	if(strcmp(var[i].id, id) == 0)
               if(strcmp(var[i].scop, scop) == 0)
                    if(var[i].initializat == 1)
                         return 1;
                    else
                         return 0;
     if(strcmp(scop, "global") != 0)
          for(int i = 0; i < nrVar; ++i)
               if(strcmp(var[i].scop, "global") == 0)
                    if(strcmp(var[i].id, id) == 0)
                         if(var[i].initializat == 1)
                         	return 1;
                    	else
                        	     return 0;
}

int varConstant(char id[100], char scop[100]){
     for(int i = 0; i < nrVar; ++i)
     	if(strcmp(var[i].id, id) == 0)
               if(strcmp(var[i].scop, scop) == 0)
                    if(var[i].constant == 1)
                         return 1;
                    else
                         return 0;
}
int varConstant_siGlobal(char id[100], char scop[100]){
     for(int i = 0; i < nrVar; ++i)
     	if(strcmp(var[i].id, id) == 0)
               if(strcmp(var[i].scop, scop) == 0)
                    if(var[i].constant == 1)
                         return 1;
                    else
                         return 0;
     if(strcmp(scop, "global") != 0)
          for(int i = 0; i < nrVar; ++i)
               if(strcmp(var[i].scop, "global") == 0)
                    if(strcmp(var[i].id, id) == 0)
                         if(var[i].constant == 1)
                         	return 1;
                    	else
                        	     return 0;
}



%}

%union {
     //char boolval[10];
     char charval;
     int intval;
     float floatval;

     int boolval;
     double val;
     char stringval[100];

     char sir[100];
     char tip[100];
     char nume[100];
     char dim[100];
     char operator_comp[100];
}

%token <stringval> NR_INTREG
%token <stringval> NR_REAL
%token <stringval> CARACTER
%token <sir> SIR
%token <tip> TIP
%token <tip> VOID
%token <nume> ID // ar trebui nume variabila ?
%token <operator_comp> COMPARARE
%token <dim> DIMENSIUNE 

%type <stringval> IDURI
%type <stringval> operatie_aritmetica
%type <stringval> operatie_booleana
%type <stringval> operatie_siruri
%type <stringval> operatie
%type <intval> op_arit_eval

//%type <intval>operatie
//%type <floatval>operatie

%token START END ASSIGN 
%token IF ELSE FOR WHILE CONSTANT
%token TRUE FALSE RETURN DEFINE
%token CONCAT_SIR COMPARE_SIR EVAL STRUCTURE 


%left '|' // sau logic
%left '&' // si logic
%left COMPARARE
%left '+' '-'
%left '*' '/' '%'
%left '!' // not logic



%start S
%%
S: {strcpy(scop[0], "global"); nrScop++; for(int i = 0; i < 100; ++i) func[i].nrParam = 0;} 
     declaratii main { 
     printf("program corect sintactic\n"); 
     printTable();
     if(nrRez > 0)
          printf("Eval:\n");
     for(int i = 0; i < nrRez; ++i)
     	printf("%d\n", rez[i]);
}
     ;

main: {strcpy(scop[nrScop], "local"); nrScop++;} START  bloc  END  
     ;

declaratii: declaratie ';'
     | declaratii declaratie ';'
     | declaratii functii 
     ;

functii: TIP ID '(' lista_parametri ')' ';' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata"); }
          addFunc(0, $1, $2, scop[nrScop - 1]); }                          
     | VOID ID '(' lista_parametri ')' ';' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata"); }
          addFunc(0, $1, $2, scop[nrScop - 1]); }
     | TIP ID '(' ')' ';' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata");}
          addFunc(0, $1, $2, scop[nrScop - 1]); }                                          
     | VOID ID '(' ')' ';' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata");}
          addFunc(0, $1, $2, scop[nrScop - 1]); }
     | TIP ID '(' lista_parametri ')' '{' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata");}
          addFunc(1, $1, $2, scop[nrScop - 1]);
          strcpy(scop[nrScop], "function"); nrScop++; } 
          bloc RETURN operatie ';' {nrScop--; strcpy(func[nrFunc - 1].return_, $10);} '}'';'
     | TIP ID '(' ')' '{' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata");}
          addFunc(1, $1, $2, scop[nrScop - 1]);
          strcpy(scop[nrScop], "function"); nrScop++; } 
          bloc RETURN operatie ';' {strcpy(func[nrFunc - 1].return_, $9); nrScop--; } '}'';'
     | VOID ID '(' lista_parametri ')' '{' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata");}
          addFunc(1, $1, $2, scop[nrScop - 1]);
          strcpy(scop[nrScop], "function"); nrScop++; }  bloc {nrScop--;} '}'';'
     | VOID ID '(' ')' '{' { if(funcExista($2, scop[nrScop - 1]) != -1) { eroare("Functia a fost deja declarata");}
          addFunc(1, $1, $2, scop[nrScop - 1]);
          strcpy(scop[nrScop], "function"); nrScop++; }  bloc {nrScop--;} '}'';'
     | DEFINE TIP ID '(' lista_parametri2 ')' '{' { if(funcExista($3, scop[nrScop - 1]) == -1) {eroare("Functia nu a fost declarata inca");}
          if(funcDefinita($3, scop[nrScop - 1]) == 1) eroare("Functia a fost deja definita");
          func[funcExista($3, scop[nrScop - 1])].definita = 1;
          strcpy(scop[nrScop], "function"); nrScop++; } 
          bloc RETURN operatie ';' {int k = funcExista($3, scop[nrScop - 1]);
          strcpy(func[k].return_, $11);nrScop--; } '}'
     | DEFINE TIP ID '(' ')' '{' { if(funcExista($3, scop[nrScop - 1]) == -1) {eroare("Functia nu a fost declarata inca.");}
          if(funcDefinita($3, scop[nrScop - 1]) == 1) eroare("Functia a fost deja definita");
          func[funcExista($3, scop[nrScop - 1])].definita = 1;
          strcpy(scop[nrScop], "function"); nrScop++; } 
          bloc RETURN operatie ';' 
          { strcpy(func[funcExista($3, scop[nrScop - 1])].return_, $10); nrScop--; } '}'
     | DEFINE VOID ID '(' lista_parametri2 ')' '{' { if(funcExista($3, scop[nrScop - 1]) == -1) {eroare("Functia nu a fost declarata inca.");}
          if(funcDefinita($3, scop[nrScop - 1]) == 1) eroare("Functia a fost deja definita");
          func[funcExista($3, scop[nrScop - 1])].definita = 1;
          strcpy(scop[nrScop], "function"); nrScop++; }  bloc {nrScop--;} '}'
     | DEFINE VOID ID '(' ')' '{' { if(funcExista($3, scop[nrScop - 1]) == -1) {eroare("Functia nu a fost declarata inca.");}
          if(funcDefinita($3, scop[nrScop - 1]) == 1) eroare("Functia a fost deja definita");
          func[funcExista($3, scop[nrScop - 1])].definita = 1;
          strcpy(scop[nrScop], "function"); nrScop++; }  bloc {nrScop--;} '}'
     ;

declaratie: TIP ID { if(varExista($2, scop[nrScop - 1]) != -1) eroare("Variabila e deja declarata");
          addVar(0, 0, $1, $2, scop[nrScop - 1], "-");}
     | TIP ID ASSIGN operatie { if(varExista($2, scop[nrScop - 1]) != -1) eroare("Variabila e deja declarata");
          addVar(0, 1, $1, $2, scop[nrScop - 1], $4);}
     | CONSTANT TIP ID ASSIGN operatie { if(varExista($2, scop[nrScop - 1]) != -1) eroare("Variabila e deja declarata");
          addVar(1, 1, $2, $3, scop[nrScop - 1], $5);}
     | TIP ID DIMENSIUNE  { if(varExista($2, scop[nrScop - 1]) != -1) eroare("Variabila e deja declarata");
          addVector(0, 0, $1, $2, scop[nrScop - 1], $3);}
     | TIP ID DIMENSIUNE ASSIGN { if(varExista($2, scop[nrScop - 1]) != -1) eroare("Variabila e deja declarata");
          addVector(0, 1, $1, $2, scop[nrScop - 1], $3);} '[' lista_array ']' 
     | CONSTANT TIP ID DIMENSIUNE ASSIGN { if(varExista($2, scop[nrScop - 1]) != -1) eroare("Variabila e deja declarata");
          addVector(1, 1, $2, $3, scop[nrScop - 1], $4);} '[' lista_array ']'
     | STRUCTURE ID '{' {strcpy(scop[nrScop], "structure"); nrScop++;} declaratii {nrScop--; } '}'
     ;

lista_parametri: param 
     | lista_parametri ','  param 
     ;

lista_parametri2: param2 
     | lista_parametri2 ','  param2 
     ;

param2 : TIP ID
     | CONSTANT TIP ID
     | TIP ID DIMENSIUNE
     | CONSTANT TIP ID DIMENSIUNE
     ;

// adaugam parametrul functiei si caracteristicile lui in structura            
param: TIP ID { int nrParam = func[nrFunc].nrParam; 
          func[nrFunc].param[nrParam].constant = 0; func[nrFunc].param[nrParam].dimensiune = 1;
          strcpy(func[nrFunc].param[nrParam].tip, $1); strcpy(func[nrFunc].param[nrParam].id, $2);
          func[nrFunc].nrParam++;}
     | CONSTANT TIP ID { int nrParam = func[nrFunc].nrParam;
          func[nrFunc].param[nrParam].constant = 1; func[nrFunc].param[nrParam].dimensiune = 1;
          strcpy(func[nrFunc].param[nrParam].tip, $2); strcpy(func[nrFunc].param[nrParam].id, $3);
          func[nrFunc].nrParam++;}
     | TIP ID DIMENSIUNE { int nrParam = func[nrFunc].nrParam;
          func[nrFunc].param[nrParam].constant = 0; func[nrFunc].param[nrParam].dimensiune = atoi($3);
          strcpy(func[nrFunc].param[nrParam].tip, $1); strcpy(func[nrFunc].param[nrParam].id, $2);
          func[nrFunc].nrParam++;}
     | CONSTANT TIP ID DIMENSIUNE { int nrParam = func[nrFunc].nrParam;
          func[nrFunc].param[nrParam].constant = 1; func[nrFunc].param[nrParam].dimensiune = atoi($3);
          strcpy(func[nrFunc].param[nrParam].tip, $2); strcpy(func[nrFunc].param[nrParam].id, $3);
          func[nrFunc].nrParam++;}
     ; 

lista_array: operatie { strcpy(var[nrVar - 1].valoare[var[nrVar - 1].dim_cur], $1); var[nrVar - 1].dim_cur++;}
     | lista_array ',' operatie { strcpy(var[nrVar - 1].valoare[var[nrVar - 1].dim_cur], $3); var[nrVar - 1].dim_cur++;}
     ;
     
/* lista instructiuni */
bloc: statement ';' 
     | bloc statement ';'
     | if_for_while
     | bloc if_for_while
     ;

/* instructiune */
statement: ID ASSIGN operatie { int k = varExista($1, scop[nrScop - 1]);
          if(k == -1)
               if( ( k = varExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Variabila nu a fost declarata");
          if(varConstant($1, scop[nrScop - 1]) == 1)
               eroare("Nu se poate modifica valoarea unei variabile constante"); 
          if(var[k].dimensiune > 1)
               eroare("Trebuie sa specificati un index pentru array");
          strcpy(var[k].valoare[0], $3);
          var[k].initializat = 1;}
     | ID '{' NR_INTREG '}' ASSIGN operatie { int k = varExista($1, scop[nrScop - 1]);
          if(k == -1)
               if( ( k = varExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Variabila nu a fost declarata");
          if(varConstant($1, scop[nrScop - 1]) == 1)
               eroare("Nu se poate modifica valoarea unei variabile constante"); 
          if(var[k].dimensiune == 1)
               eroare("Variabila nu este de tipul array");
          strcpy(var[k].valoare[(int)atof($3)], $6);
     }
     | ID_S ASSIGN operatie 
     | declaratie 
     | operatie 
     | EVAL '(' op_arit_eval ')' {rez[nrRez++] = $3;}
     ;

ID_S: ID '.' ID_S
     | ID '.' ID
     ;

ID_STRUCT: ID '.' ID_STRUCT
     | ID '.' ID
     | ID '.' ID '(' ')'
     | ID '.' ID '(' lista_apel ')'
     ;

if_for_while: IF '(' conditie ')' '{' bloc '}'
     | IF '(' conditie ')' '{' bloc '}' ELSE '{' bloc '}'
     | WHILE '(' conditie ')' '{' bloc '}'
     | FOR '(' statement ';' conditie ';' ID ASSIGN operatie ')' '{' bloc '}' 
     | FOR '(' statement ';' conditie ';' ')' '{' bloc '}' 
     | FOR '(' ';' conditie ';' ID ASSIGN operatie ')' '{' bloc '}' 
     | FOR '(' ';' conditie ';'  ')' '{' bloc '}'      // toate variantele de for
     ;

conditie: operatie 
     ;

operatie: '(' operatie ')' { strcpy($$, $2); }
     | operatie_aritmetica { strcpy($$, $1); }
     | operatie_booleana { strcpy($$, $1); }
     | operatie_siruri { strcpy($$, $1); }
     | operatie COMPARARE operatie { char *s;
         if(strcmp($2, ">") == 0) {strcpy($$, ftoa(atof($1) > atof($3), s)); }
         else if(strcmp($2, "<") == 0) {strcpy($$, ftoa(atof($1) < atof($3), s)); }
         else if(strcmp($2, ">=") == 0) {strcpy($$, ftoa(atof($1) >= atof($3), s)); }
         else if(strcmp($2, "<=") == 0) {strcpy($$, ftoa(atof($1) <= atof($3), s)); }
         else if(strcmp($2, "==") == 0) {strcpy($$, ftoa(atof($1) == atof($3), s)); }
         else if(strcmp($2, "!=") == 0) {strcpy($$, ftoa(atof($1) != atof($3), s)); }  }
     | IDURI { strcpy($$, $1); }
     ;


IDURI: ID { int k = varExista($1, scop[nrScop - 1]);
          if(k == -1)
               if( ( k = varExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Variabila nu a fost declarata");
          if(var[k].initializat == 0)
               eroare("Variabila nu a fost initializata");
          if(var[k].dimensiune > 1)
               eroare("Trebuie sa specificati un index pentru array");
          strcpy($$, var[k].valoare[0]);}
     | ID '{' NR_INTREG '}' { int k = varExista($1, scop[nrScop - 1]);
          if(k == -1)
               if( ( k = varExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Variabila nu a fost declarata");
          if(var[k].dimensiune <= atof($3))
               eroare("Ati depasit lungimea array-ului");
          strcpy($$, var[k].valoare[(int)atof($3)]);} 
     | ID '(' lista_apel ')' { int k = funcExista($1, scop[nrScop - 1]); 
          if(k == -1)
                if( ( k = funcExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Functia nu a fost declarata");
          if(func[k].definita == 0)
               eroare("Functia nu a fost definita");
          strcpy($$, func[k].return_); } 
     | ID '(' ')' { int k = funcExista($1, scop[nrScop - 1]); 
          if(k == -1)
                if( ( k = funcExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Functia nu a fost declarata");
          if(func[k].definita == 0)
               eroare("Functia nu a fost definita");
          strcpy($$, func[k].return_);} 
     | ID_STRUCT { ; } 
     ;

lista_apel: operatie
     | operatie ',' lista_apel
     ;
     
op_arit_eval: '(' op_arit_eval ')' { $$ = $2;}
     | NR_INTREG { $$ = atoi($1); }
     | ID {
          int k = varExista($1, scop[nrScop - 1]);
          if(k == -1)
               if( ( k = varExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Variabila nu a fost declarata");
          if(var[k].initializat == 0)
               eroare("Variabila nu a fost initializata");
          if(var[k].dimensiune > 1)
               eroare("Trebuie sa specificati un index pentru array");
          if(strcmp(var[k].tip, "int") != 0)
               eroare("O variabila nu e de tipul int");
          $$ = atoi(var[k].valoare[0]);
     }
     | ID '{' NR_INTREG '}' {
          int k = varExista($1, scop[nrScop - 1]);
          if(k == -1)
               if( ( k = varExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Variabila nu a fost declarata");
          if(var[k].dimensiune <= atof($3))
               eroare("Ati depasit lungimea array-ului");
          if(strcmp(var[k].tip, "int") != 0)
               eroare("Array-ul nu e de tipul int");
          $$ = atoi(var[k].valoare[(int)atof($3)]);
     }
     | ID '(' lista_apel ')' {
          int k = funcExista($1, scop[nrScop - 1]); 
          if(k == -1)
                if( ( k = funcExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Functia nu a fost declarata");
          if(func[k].definita == 0)
               eroare("Functia nu a fost definita");
          if(strcmp(func[k].tip, "int") != 0)
               eroare("Valoarea de return a functiei nu e de tipul int");
          $$ = (int)atof(func[k].return_);
     }
     | ID '(' ')' {
          int k = funcExista($1, scop[nrScop - 1]); 
          if(k == -1)
                if( ( k = funcExista_siGlobal($1, scop[nrScop - 1] ) ) == -1)
                    eroare("Functia nu a fost declarata");
          if(func[k].definita == 0)
               eroare("Functia nu a fost definita");
          if(strcmp(func[k].tip, "int") != 0)
               eroare("Valoarea de return a functiei nu e de tipul int");
          $$ = (int)atof(func[k].return_);
     }
     | op_arit_eval '+' op_arit_eval {$$ = $1 + $3;}
     | op_arit_eval '-' op_arit_eval {$$ = $1 - $3;}
     | op_arit_eval '*' op_arit_eval {$$ = $1 * $3;}
     | op_arit_eval '/' op_arit_eval {$$ = $1 / $3;}
     | op_arit_eval '%' op_arit_eval {$$ = $1 % $3;}
     ;

operatie_aritmetica: NR_INTREG { strcpy($$, $1); }
     | NR_REAL { strcpy($$, $1); }
     | CARACTER { int x = $1[0]; char s[3]; 
          for(int i = 2; i >= 0; --i){ 
               s[i] = x % 10 + '0'; x /= 10; 
          } strcpy($$, s);}
     | operatie '+' operatie { float rez = atof($1) + atof($3); char*s; strcpy($$, ftoa(rez, s));  }
     | operatie '-' operatie { float rez = atof($1) - atof($3); char*s; strcpy($$, ftoa(rez, s));  } 
     | operatie '*' operatie { float rez = atof($1) * atof($3); char*s; strcpy($$, ftoa(rez, s));  }
     | operatie '/' operatie { float rez = atof($1) / atof($3); char*s; strcpy($$, ftoa(rez, s));  }
     | operatie '%' operatie { float rez = atoi($1) % atoi($3); char*s; strcpy($$, ftoa(rez, s));  }
     | COMPARE_SIR '(' SIR ',' SIR ')' { char*s; strcpy($$, ftoa(strcmp($3, $5), s)); }
     | COMPARE_SIR '(' ID  ','  ID ')' { char*s; strcpy($$, ftoa(strcmp($3, $5), s)); }
     | COMPARE_SIR '(' ID  ',' SIR ')' { char*s; strcpy($$, ftoa(strcmp($3, $5), s)); }
     | COMPARE_SIR '(' SIR ','  ID ')' { char*s; strcpy($$, ftoa(strcmp($3, $5), s)); }
     ;

operatie_booleana: TRUE { strcpy($$, "1"); }
     | FALSE { strcpy($$, "0"); }
     | '!' operatie { float x = !atof($2); char*s; strcpy($$, ftoa(x, s)); }
     | operatie '&' operatie { float x = atof($1) && atof($3); char*s; strcpy($$, ftoa(x, s)); }
     | operatie '|' operatie { float x = atof($1) && atof($3); char*s; strcpy($$, ftoa(x, s)); }
     ;

// si aici de pus
operatie_siruri: SIR { strcpy($$, $1);}
     | CONCAT_SIR '(' ID ',' ID ')' {;}
     | CONCAT_SIR '(' ID ',' SIR ')' {;}
     ;
        

// operatie: '(' operatie ')' {;}
//      | termen {;}
//      | '!' operatie {;}
//      | operatie '&' operatie
//      | operatie '|' operatie
//      | operatie COMPARARE operatie
//      | operatie '+' operatie {$$ = $1 + $3;}
//      | operatie '-' operatie
//      | operatie '*' operatie
//      | operatie '/' operatie
//      | operatie '%' operatie
//      | CONCAT_SIR '(' termen ',' termen ')' {;}
//      | COMPARE_SIR '(' termen ',' termen ')' {;}
//      ;

// valoare, variabila, apel de functie
// termen: NR_INTREG
//      | NR_REAL
//      | ID       // nume variabila
//      | TRUE
//      | FALSE 
//      | CARACTER
//      | SIR
//      | ID '{' NR_INTREG '}' // indexare vector
//      | ID '(' lista_apel ')' // apel de functie
//      | ID '(' ')'
//      | ID_STRUCT
//      ;

%%
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 
