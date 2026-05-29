#ifndef EVAL_H
#define EVAL_H

#include "ast.h"

/* Função que percorre a árvore e a executa/avalia */
double eval_ast(ASTNode *node);

#endif