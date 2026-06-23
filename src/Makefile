CC = gcc
CFLAGS = -Wall -g
LDFLAGS = -lfl

# Arquivos fonte em C criados manualmente
SRCS = ast.c symtab.c semantic.c eval.c

# O parser é gerado através do bison e flex
TARGET = parser

all: $(TARGET)

# Gera os arquivos do bison (parser)
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

# Gera os arquivos do flex (scanner)
lex.yy.c: scanner.l parser.tab.h
	flex scanner.l

# Compila tudo e gera o executável
$(TARGET): parser.tab.c lex.yy.c $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c $(SRCS) $(LDFLAGS)

# Regra para cobertura: injeta as flags necessárias, compila, roda os testes e gera o HTML
coverage: CFLAGS += --coverage -O0
coverage: LDFLAGS += --coverage
coverage: clean $(TARGET)
	# Executa os testes (eles rodam o parser compilado com --coverage)
	bash ./run_tests.sh

	# Captura os dados de cobertura do diretório atual
	lcov --capture --directory . --output-file coverage.info

	# Remove arquivos gerados por flex/bison e cabeçalhos do relatório para deixar só o código escrito à mão
	lcov --remove coverage.info '*/lex.yy.c' '*/parser.tab.c' '*/parser.tab.h' '*/scanner.l' '*/parser.y' -o coverage.info 2>/dev/null || true

	# Gera o relatório HTML na pasta coverage_html
	genhtml coverage.info --output-directory coverage_html --legend

	@echo ""
	@echo "Relatório gerado em: src/coverage_html/index.html"

# Limpeza geral
clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c *.o *.gcno *.gcda coverage.info
	rm -rf coverage_html
