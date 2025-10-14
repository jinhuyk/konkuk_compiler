%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX 4096
/* lexer / error */
int yylex(void);
void yyerror(const char *s);

char exprn[MAX]="";

/* --- 심볼테이블(아주 단순) --- */
typedef struct Sym {
  char *name;
  double   value;
  struct Sym *next;
} Sym;
static Sym *symtab = NULL;

static Sym* lookup(const char *name){
  for (Sym *p = symtab; p; p = p->next)
    if (strcmp(p->name, name) == 0) return p;
  return NULL;
}
static double getval(const char *name){
  Sym *s = lookup(name);
  if (!s) {
    fprintf(stderr, "undefined variable: %s\n", name);
    return 0.0;
  }
  return s->value;
}
static void setval(const char *name, double v){
  Sym *s = lookup(name);
  if (!s) {
    s = (Sym*)malloc(sizeof(Sym));
    s->name = strdup(name);
    s->next = symtab;
    symtab = s;
  }
  s->value = v;
}

static void getexper(double a, double b, char o1, char* o2){
  if(strlen(exprn)+3>=MAX){yyerror("EXPRESSION IS MAX, cut expression");}
  if(o1 =='=')snprintf(exprn + strlen(exprn),sizeof(exprn)-strlen(exprn),"%c %c %g -> ",o2,o1,b);
  else snprintf(exprn + strlen(exprn),sizeof(exprn)-strlen(exprn),"%g %c %g -> ",a,o1,b);
}
%}

/* --- 토큰/타입 --- */
%union { double ival; char *sval; }

%token <ival> T_NUMBER
%token <sval> T_ID
%token        T_PRINT

%left '+' '-'
%left '*' '/' '%'
%right UMINUS

%type <ival> expr stmt
%start input

%%

/* 줄 단위로 즉시 reduce → 출력 */
input
  : /* empty */
  | input line 
  ;

line
  : stmt '\n'              { printf("%g\n", $1); exprn[0] = '\0';}
  | '\n'                   { /* 빈 줄 무시 */ }
  | stmt ';'                {  printf("%g\n", $1);exprn[0] = '\0';}
  | ';'                     {/* skip*/}
  | error '\n'             { yyerrok; /* 에러 줄 스킵 */ }
  ;

stmt
  : expr                   { $$ = $1; }
  | T_ID '=' expr          { setval($1, $3); $$ = $3; free($1); }
  | T_PRINT expr           {printf("%s",exprn); $$ = $2; }  /* print도 값 출력(line에서 일괄 출력) */
  ;

expr
  : expr '+' expr          {getexper($1,$3,'+',""); $$ = $1 + $3; }
  | expr '-' expr          {getexper($1,$3,'-',""); $$ = $1 - $3; }
  | expr '*' expr          {getexper($1,$3,'*',""); $$ = $1 * $3; }
  | expr '/' expr          {getexper($1,$3,'/',""); if ($3 == 0) { yyerror("mod by zero");       $$ = 0.0; } else $$ = $1 / $3; }
  | expr '%' expr          { if ($3 == 0) { yyerror("mod by zero");       $$ = 0.0; } 
                                      if ((int)$1 == $1 && (int)$3==$3 ){
                                        getexper($1,$3,'%',"");
                                      $$ = (int)$1 % (int)$3;
                                  }
                                  else {yyerror("value is not integer"); $$ = 0.0; }
                            }
  | '-' expr %prec UMINUS  { $$ = -$2; }
  | '(' expr ')'           { $$ = $2; }
  | T_NUMBER               { $$ = $1; }
  | T_ID                   {getexper(0,getval($1),'=',$1); $$ = getval($1); free($1); }
  ;

%%

void yyerror(const char *s){ fprintf(stderr, "parse error: %s\n", s); }
int main(void){
  return yyparse();
}
