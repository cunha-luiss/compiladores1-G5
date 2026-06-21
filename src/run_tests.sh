#!/bin/bash
cd "$(dirname "$0")"
echo "Executando testes de análise semântica..."
make > /dev/null 2>&1
for file in tests/*.txt; do
    echo "=========================="
    echo "Arquivo: $file"
    echo "--------------------------"
    ./parser --test < "$file"
    echo ""
done