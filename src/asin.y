
%{
#include "header.h"
#include <stdio.h>
#include <string.h>
#include "libtds.h" 
%}

%token PARA_ PARC_ MAS_ MENOS_ POR_ DIV_ AND_ OR_ IGUAL_ IGUALIGUAL_ DIF_ MAYOR_ MENOR_ MAYIG_ MENIG_ TRUE_ FALSE_ INT_ BOOL_ RETURN_ READ_ PRINT_ IF_ ELSE_ CORA_ CORC_ COMA_ LLA_ LLC_ PYC_ EXC_ FOR_ COMENT_
%token CTE_ ID_

%%
programa      : listDecla
              ;

listDecla     : decla
              | listDecla decla
              ;

decla         : declaVar
              | declaFunc
              ;

declaVar      : tipoSimp ID_ PYC_
              | tipoSimp ID_ IGUAL_ const PYC_
              | tipoSimp ID_ CORA_ CTE_ CORC_ PYC_
              ;

const         : CTE_
              | TRUE_
              | FALSE_
              ;

tipoSimp      : INT_
              | BOOL_
              ;

declaFunc     : tipoSimp ID_ PARA_ paramForm PARC_ bloque
              ;

paramForm     :
              | listParamForm
              ;

listParamForm : tipoSimp ID_
              | tipoSimp ID_ COMA_ listParamForm
              ;

bloque        : LLA_ declaVarLocal listInst RETURN_ expre PYC_ LLC_
              ;

declaVarLocal :
              | declaVarLocal declaVar
              ;

listInst      :
              | listInst inst
              ;

inst          : LLA_ listInst LLC_
              | instExpre
              | instEntSal
              | intSelec
              | instIter
              ;

instExpre     : expre PYC_
              | PYC_
              ;

instEntSal    : READ_ PARA_ ID_ PARC_ PYC_
              | PRINT_ PARA_ expre PARC_ PYC_
              ;

intSelec      : IF_ PARA_ expre PARC_ inst ELSE_ inst
              ;

instIter      : FOR_ PARA_ expreOP PYC_ expre PYC_ expreOP PARC_ inst
              ;

expreOP       :
              | expre
              ;

expre         : expreLogic
              | ID_ IGUAL_ expre
              | ID_ CORA_ expre CORC_ IGUAL_ expre
              ;

expreLogic    : expreIgual
              | expreLogic opLogic expreIgual
              ;

expreIgual    : expreRel
              | expreIgual opIgual expreRel
              ;

expreRel      : expreAd
              | expreRel opRel expreAd
              ;

expreAd       : expreMul
              | expreAd opAd expreMul
              ;

expreMul      : expreUna
              | expreMul opMul expreUna
              ;

expreUna      : expreSufi
              | opUna expreUna
              ;

expreSufi     : const
              | PARA_ expre PARC_
              | ID_
              | ID_ CORA_ expre CORC_
              | ID_ PARA_ paramAct PARC_
              ;

paramAct      :
              | listParamAct
              ;

listParamAct  : expre
              | expre COMA_ listParamAct
              ;

opLogic       : AND_
              | OR_
              ;

opIgual       : IGUALIGUAL_
              | DIF_
              ;

opRel         : MAYOR_
              | MENOR_
              | MAYIG_
              | MENIG_
              ;

opAd          : MAS_
              | MENOS_
              ;

opMul         : POR_
              | DIV_
              ;

opUna         : MAS_
              | MENOS_
              | EXC_
              ;
%%
