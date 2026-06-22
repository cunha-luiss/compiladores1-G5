#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

make clean >/dev/null
make >/dev/null

passed=0
failed=0

run_valid() {
    local file="$1"
    local output

    output="$(mktemp)"
    if ./parser < "$file" >"$output" 2>&1 &&
       ! grep -q "Erro semantico" "$output"; then
        echo "PASS valido: $file"
        passed=$((passed + 1))
    else
        echo "FAIL valido: $file"
        cat "$output"
        failed=$((failed + 1))
    fi
    rm -f "$output"
}

run_invalid() {
    local file="$1"
    local expected="$2"
    local output

    output="$(mktemp)"
    if ./parser < "$file" >"$output" 2>&1; then
        echo "FAIL invalido (retorno zero): $file"
        cat "$output"
        failed=$((failed + 1))
    elif grep -Fq "$expected" "$output" &&
         grep -Fq "Execucao abortada" "$output"; then
        echo "PASS invalido: $file"
        passed=$((passed + 1))
    else
        echo "FAIL invalido (mensagem inesperada): $file"
        cat "$output"
        failed=$((failed + 1))
    fi
    rm -f "$output"
}

run_valid tests/semantic/valid_basic.txt
run_valid tests/semantic/valid_scope_shadow.txt
run_valid tests/semantic/valid_outer_visibility.txt
run_valid tests/semantic/valid_types.txt
run_valid tests/operacao_mat.txt
run_valid tests/if_true_statement.txt
run_valid tests/if_false_statement.txt
run_valid tests/while_false.txt

run_invalid tests/semantic/invalid_use.txt \
    "Erro semantico na linha 1: variavel 'x' nao declarada"
run_invalid tests/semantic/invalid_assignment.txt \
    "Erro semantico na linha 1: variavel 'x' nao declarada"
run_invalid tests/semantic/invalid_redeclaration.txt \
    "Erro semantico na linha 2: variavel 'x' redeclarada no mesmo escopo"
run_invalid tests/semantic/invalid_out_of_scope.txt \
    "Erro semantico na linha 4: variavel 'x' nao declarada"
run_invalid tests/semantic/invalid_expression.txt \
    "Erro semantico na linha 1: variavel 'x' nao declarada"
run_invalid tests/semantic/invalid_multiple.txt \
    "Erro semantico na linha 4: variavel 'z' nao declarada"

echo
echo "Resultado: $passed passou/passaram; $failed falhou/falharam."

if [ "$failed" -ne 0 ]; then
    exit 1
fi
