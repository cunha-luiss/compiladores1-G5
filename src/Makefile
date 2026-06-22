CC ?= gcc
BISON ?= bison
FLEX ?= flex
CFLAGS ?= -std=c11 -Wall -Wextra -Wpedantic

TARGET = parser
SOURCES = parser.tab.c lex.yy.c ast.c symtab.c semantic.c eval.c

.PHONY: all clean test

all: $(TARGET)

$(TARGET): parser.tab.c lex.yy.c ast.c ast.h symtab.c symtab.h semantic.c semantic.h eval.c eval.h types.h
	$(CC) $(CFLAGS) -o $@ $(SOURCES)

parser.tab.c parser.tab.h: parser.y ast.h types.h
	$(BISON) -d parser.y

lex.yy.c: scanner.l parser.tab.h types.h
	$(FLEX) scanner.l

test: $(TARGET)
	bash run_tests.sh

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c *.o
