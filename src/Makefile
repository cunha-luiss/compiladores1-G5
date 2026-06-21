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
coverage: CFLAGS += --coverage
coverage: LDFLAGS += --coverage
coverage: clean $(TARGET)
	# Executa os testes (eles rodarão o parser compilado com --coverage)
	bash ./run_tests.sh
	
	# Captura os dados de cobertura do diretório atual ignorando bibliotecas padrão, se possível
	lcov --capture --directory . --output-file coverage.info
	
	# Opcional: remover arquivos de bibliotecas de sistema, flex e bison para limpar o relatorio
	# lcov --remove coverage.info '/usr/*' '*/lex.yy.c' '*/parser.tab.c' '*/parser.tab.h' -o coverage.info
	
	# Gera o relatório HTML na pasta coverage_html
	genhtml coverage.info --output-directory coverage_html

# Limpeza geral
clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c *.o *.gcno *.gcda coverage.info
	rm -rf coverage_html
