#!/bin/bash
cd "$(dirname "$0")"
echo "Executando testes do interpretador..."
fail=0
for file in $(find tests -name "*.txt" | sort); do
    echo "=========================="
    echo "Arquivo: $file"
    echo "--------------------------"
    # Limita cada teste a 3s para evitar loops infinitos do interpretador
    timeout 3s ./parser --test < "$file"
    status=$?
    if [ $status -eq 124 ]; then
        echo "[timeout apos 3s]"
        fail=$((fail+1))
    elif [ $status -ne 0 ]; then
        fail=$((fail+1))
    fi
    echo ""
done
echo "================================="
echo "Total de testes com falha/timeout: $fail"
exit $fail