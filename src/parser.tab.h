/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 33 "parser.y"

    typedef struct ASTNode ASTNode;

#line 53 "parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    NUM = 258,                     /* NUM  */
    NUMFLOAT = 259,                /* NUMFLOAT  */
    ID = 260,                      /* ID  */
    STRING_LITERAL = 261,          /* STRING_LITERAL  */
    CHAR_LITERAL = 262,            /* CHAR_LITERAL  */
    KW_BOOL = 263,                 /* KW_BOOL  */
    BOOL_TYPE = 264,               /* BOOL_TYPE  */
    DOUBLE_TYPE = 265,             /* DOUBLE_TYPE  */
    KW_LONG = 266,                 /* KW_LONG  */
    KW_SIZE = 267,                 /* KW_SIZE  */
    TYPE_MODIFIER = 268,           /* TYPE_MODIFIER  */
    TYPE_SPECIFIER = 269,          /* TYPE_SPECIFIER  */
    KW_TYPE_MODIFIER = 270,        /* KW_TYPE_MODIFIER  */
    KW_DECIMAL32 = 271,            /* KW_DECIMAL32  */
    KW_DECIMAL64 = 272,            /* KW_DECIMAL64  */
    KW_DECIMAL128 = 273,           /* KW_DECIMAL128  */
    KW_COMPLEX = 274,              /* KW_COMPLEX  */
    KW_IMAGINARY = 275,            /* KW_IMAGINARY  */
    KW_TYPE_DECLARATION = 276,     /* KW_TYPE_DECLARATION  */
    KW_DECLARATION_OF_A_COMPOUND_TYPE = 277, /* KW_DECLARATION_OF_A_COMPOUND_TYPE  */
    KW_DECLARATION_OF_A_UNION_TYPE = 278, /* KW_DECLARATION_OF_A_UNION_TYPE  */
    ENUMERATION_TYPE = 279,        /* ENUMERATION_TYPE  */
    KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE = 280, /* KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE  */
    IF_STATEMENT = 281,            /* IF_STATEMENT  */
    ELSE_STATEMENT = 282,          /* ELSE_STATEMENT  */
    KW_WHILE = 283,                /* KW_WHILE  */
    DO_LOOP = 284,                 /* DO_LOOP  */
    LOOP = 285,                    /* LOOP  */
    SWITCH_STATEMENT = 286,        /* SWITCH_STATEMENT  */
    KW_SWITCH = 287,               /* KW_SWITCH  */
    DEFAULT_STATEMENT = 288,       /* DEFAULT_STATEMENT  */
    CONTINUE_STATEMENT = 289,      /* CONTINUE_STATEMENT  */
    DECLARATION = 290,             /* DECLARATION  */
    STATEMENT = 291,               /* STATEMENT  */
    RETURN_STATEMENT = 292,        /* RETURN_STATEMENT  */
    KW_STATIC = 293,               /* KW_STATIC  */
    STORAGE_CLASS_SPECIFIER = 294, /* STORAGE_CLASS_SPECIFIER  */
    AUTOMATIC_DURATION_STORAGE_CLASS_SPECIFIER = 295, /* AUTOMATIC_DURATION_STORAGE_CLASS_SPECIFIER  */
    INLINE_FUNCTION_SPECIFIER = 296, /* INLINE_FUNCTION_SPECIFIER  */
    TYPE_QUALIFIER = 297,          /* TYPE_QUALIFIER  */
    KW_TYPE_QUALIFIER = 298,       /* KW_TYPE_QUALIFIER  */
    CONST_LITERAL = 299,           /* CONST_LITERAL  */
    SPECIFIER = 300,               /* SPECIFIER  */
    THREAD_STORAGE = 301,          /* THREAD_STORAGE  */
    KW_THREAD_STORAGE_CLASS_SPECIFIER = 302, /* KW_THREAD_STORAGE_CLASS_SPECIFIER  */
    AUTO_TYPE_INFERENCE = 303,     /* AUTO_TYPE_INFERENCE  */
    KW_ALIGNAS = 304,              /* KW_ALIGNAS  */
    KW_ALIGNOF = 305,              /* KW_ALIGNOF  */
    KW_ALIGNMENT = 306,            /* KW_ALIGNMENT  */
    KW_ATOMIC = 307,               /* KW_ATOMIC  */
    KW_STATIC_ASSERT = 308,        /* KW_STATIC_ASSERT  */
    STATIC_ASSERT_DECLARATION = 309, /* STATIC_ASSERT_DECLARATION  */
    KW_GENERIC = 310,              /* KW_GENERIC  */
    KW_NORETURN = 311,             /* KW_NORETURN  */
    TRUE_LITERAL = 312,            /* TRUE_LITERAL  */
    FALSE_LITERAL = 313,           /* FALSE_LITERAL  */
    POINTER_CONSTANT = 314,        /* POINTER_CONSTANT  */
    OPERATOR = 315,                /* OPERATOR  */
    KW_OPERATOR = 316,             /* KW_OPERATOR  */
    KW_OPERATOR_THAT_REMOVES_QUALIFIERS = 317, /* KW_OPERATOR_THAT_REMOVES_QUALIFIERS  */
    PLUS = 318,                    /* PLUS  */
    MINUS = 319,                   /* MINUS  */
    TIMES = 320,                   /* TIMES  */
    DIVIDE = 321,                  /* DIVIDE  */
    LPAREN = 322,                  /* LPAREN  */
    RPAREN = 323,                  /* RPAREN  */
    NEWLINE = 324,                 /* NEWLINE  */
    COMPARATION = 325,             /* COMPARATION  */
    EQUAL = 326,                   /* EQUAL  */
    SEMICOLON = 327,               /* SEMICOLON  */
    LBRACE = 328,                  /* LBRACE  */
    RBRACE = 329,                  /* RBRACE  */
    LESS_EQUAL = 330,              /* LESS_EQUAL  */
    GREATER_EQUAL = 331,           /* GREATER_EQUAL  */
    NOT_EQUAL = 332,               /* NOT_EQUAL  */
    LOGICAL_AND = 333,             /* LOGICAL_AND  */
    LOGICAL_OR = 334,              /* LOGICAL_OR  */
    LESS = 335,                    /* LESS  */
    GREATER = 336                  /* GREATER  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 38 "parser.y"

    int intValue;
    float floatValue;
    char *str;
    ASTNode *node;

#line 158 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
