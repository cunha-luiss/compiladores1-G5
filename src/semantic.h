#ifndef SEMANTIC_H
#define SEMANTIC_H

#include "ast.h"

/* Percorre a AST validando as regras semânticas e populando a tabela de símbolos.
   Retorna o número de erros semânticos encontrados. */
int analyze_ast(ASTNode *node);

#endif
