
%{
#include "header.h"
#include <stdio.h>
#include <string.h>
#include "libtds.h" 
%}

%token PARA_ PARC_ MAS_ MENOS_ POR_ DIV_ AND_ OR_ IGUAL_ IGUALIGUAL_ DIF_ MAYOR_ MENOR_ MAYIG_ MENIG_ TRUE_ FALSE_ INT_ BOOL_ RETURN_ READ_ PRINT_ IF_ ELSE_ CORA_ CORC_ COMA_ LLA_ LLC_ PYC_ EXC_ FOR_ COMENT_
%token<ident> ID_
%token<cent>  CTE_

%union {
char *ident;
int cent;
}

%type  <list> listDecla 
%type  <texp> 



%%
programa      : listDecla 
        {
            niv = 0;
            dvar = 0;
            cargaContexto(niv);
            if(verTdS) mostrarTdS();
        } 
        ;

listDecla    
	: decla { $$ = $1; } 
	|listDecla decla { $$ = $1 + $2; }
    ;

decla
	: declaVar { $$ = 0; }
	| declaFunc { $$ = $1; } -- EXPLICAR
    ;

-- declaVar      : tipoSimp ID_ PYC_
--               | tipoSimp ID_ IGUAL_ const PYC_
--               | tipoSimp ID_ CORA_ CTE_ CORC_ PYC_
--               ;
declaVar : tipoSimp ID_ PYC_
        {
            // Intentar insertar la variable en la TdS
            if (!insTdS($2, VARIABLE, $1.t, niv, dvar, -1)) {  
                yyerror("Variable ya declarada");
            } else {
                // Reservar espacio para la variable
                dvar += TALLA_TIPO_SIMPLE;
            }
        }
        | tipoSimp ID_ IGUAL_ const PYC_      
            // Intentar insertar la variable en la TdS
            if (!insTdS($2, VARIABLE, $1.t, niv, dvar, -1)) {
                yyerror("Variable ya declarada");
            } else {
                // Comprobar la compatibilidad de tipos
                if ($4.t != $1.t) {
                    yyerror("Error: Tipo de inicialización incompatible");
                    eliminarUltimaEntradaTdS(); // Eliminar variable de la TdS
                } else {
                    // Reservar espacio para la variable
                    dvar += TALLA_TIPO_SIMPLE;
                }
            }
        }
        | tipoSimp ID_ CORA_ CTE_ CORC_ PYC_  
        {
            // Verificar que el tamaño del array sea válido
            if ($4 <= 0) {
                yyerror("Error: Tamaño del array inválido");
            } else {
                // Insertar el array en la Tabla de Arrays (TdA)
                int ref = insTdA($1.t, $4); // Tipo de los elementos y tamaño
                if (!insTdS($2, VARIABLE, T_ARRAY, niv, dvar, ref)) {
                    yyerror("Array ya declarado");
                } else {
                    // Reservar espacio en memoria para el array
                    dvar += $4 * TALLA_TIPO_SIMPLE;
                }
            }
        }
        ;

-- PREGUNTAR:
--            $1, TRUE, FALSE es correcto?  o directamente poner 1 o 2
--            hay que comprobar la tdS

const         : CTE_ { 
                        $$ = $1
                        $$.t = $1.t
                    
                     }

              | TRUE_ {
                        $$ = TRUE
                        $$.t = T_LOGICO
                      }

              | FALSE_ {
                        $$ = FALSE
                        $$.t = T_LOGICO
                       }
              ;


tipoSimp      : INT_ {$$ = T_ENTERO}
              | BOOL_ {$$ = T_LOGICO}
              ;
-- PREGUNTAR: hemos pusto $$ en vez de $$.t para tipoSimp, porque solo puede contener tipos

-- declaFunc   : tipoSimp ID_ PARA_ paramForm PARC_ bloque


declaFunc
    -- :    $1    $2
       : tipoSimp ID_ PARA_ paramForm PARC_ bloque
         {
             int tipo = $1;
             char *nombre = $2;
             dvar = 0;
             niv++;
             cargaContexto(niv);
        
             int refDom = insTdD(-1, T_VACIO);
             if (!insTdS($2, FUNCION, $1, niv, 0, refDom)) {
                 yyerror("Error: la función ya está declarada.");
             }
         
             if (verTdS) {
                 mostrarTdS();
             }
             descargaContexto(niv);
             niv--;
         }
       ;

-- PREGUNTA TOCHA, cuando comprobamos los tipos?
-- comprobamos dentro de la regla declaFunc, que tenemos tipoSimp y bloque?
-- o comprobamos luego mas adelante en la regla bloque, usando: tabla de Simbolos con obtTdS!!.
-- hay que poner cargarContexto aqui? declarando una funcion seguimos en contexto 0?

paramForm     : 
              | listParamForm
              ;

listParamForm : tipoSimp ID_ 
              | tipoSimp ID_ COMA_ listParamForm
              ;

bloque        : LLA_ declaVarLocal listInst RETURN_ expre PYC_ LLC_ 
                {
                    if () {
                        yyerror("Error: Tipo de retorno incompatible");
                    }   
                }
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
