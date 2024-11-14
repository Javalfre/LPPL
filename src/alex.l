
%{
#include "header.h"
#include "asin.h"

#define  retornar(x) {if (verbosidad) ECHO ; return (x) ; }
%}
/*----------------------------------------------------------------------
  Dado que las funciones "input()" y "unput(c)" son costosas y no las
  utilizaremos, evitaremos que se generen automaticamente sus rutinas
  correspondientes desactivandolas mediante las siguientes opciones:
----------------------------------------------------------------------*/
%option noinput
%option nounput
/*----------------------------------------------------------------------
  Para mantener el numero de linea actual en la variable global yylineno
----------------------------------------------------------------------*/
%option yylineno

delimitador     [ \t]+
digito          [0-9]
letra           [a-zA-Z_]
variable        {letra}({letra}|{digito})*
entero          {digito}+
real1		        {digito}*\.{digito}+
real2           {digito}+\.{digito}*
real            {real1}|{real2}
comentario      \/\/.*\n
saltodelinea    [\n]


%%

{saltodelinea}  { fprintf(stdout, "\n %3d.- ", yylineno); }
{delimitador}   {if (verbosidad) ECHO ; }
{comentario}    { if (verbosidad) ECHO ; }
"+"             { retornar (MAS_) ;}
"-"             { retornar (MENOS_) ; }
"*"             { retornar (POR_) ; }
"/"             { retornar (DIV_) ; }
"("             { retornar (PARA_) ; }
")"             { retornar (PARC_) ; }
"&&"            { retornar (AND_) ; }
"||"            { retornar (OR_) ; }
"="             { retornar (IGUAL_) ; }
"=="            { retornar (IGUALIGUAL_) ; }
"!="            { retornar (DIF_) ; }
">"             { retornar (MAYOR_) ; }
"<"             { retornar (MENOR_) ; }
">="            { retornar (MAYIG_) ; }
"<="            { retornar (MENIG_) ; }
"true"          { retornar (TRUE_) ; }
"false"         { retornar (FALSE_) ; }
"int"           { retornar (INT_) ; }
"bool"          { retornar (BOOL_) ; }
"return"        { retornar (RETURN_) ; }
"read"          { retornar (READ_) ; }
"print"         { retornar (PRINT_) ; }
"if"            { retornar (IF_) ; }
"else"          { retornar (ELSE_) ; }
"for"           { retornar (FOR_) ; }
"["             { retornar (CORA_) ; }
"]"             { retornar (CORC_) ; }
","             { retornar (COMA_) ; }
"{"             { retornar (LLA_) ; }
"}"             { retornar (LLC_) ; }
";"             { retornar (PYC_) ; }
"!"             { retornar (EXC_) ; }

{entero}        { yylval.cent = atoi(yytext); retornar(CTE_); }
{real}        	{ yylval.cent = (int) atof(yytext); retornar(CTE_); }
{variable}      { yylval.ident = strdup(yytext); retornar(ID_); }



.				{ yyerror("Caracter desconocido") ;}
%%
