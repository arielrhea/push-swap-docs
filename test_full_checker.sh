#!/bin/bash

# --- Colores (usando tput) ---
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4) 
NC=$(tput sgr0) # No Color

# --- Configuración ---
PUSH_SWAP_EXEC="./push_swap"
OFFICIAL_CHECKER_EXEC="./checker_linux"
# !!! ======================================================== !!!
# !!! IMPORTANTE: Edita la siguiente línea con el nombre       !!!
# !!!             o ruta de TU PROPIO checker del bonus.       !!!
MY_CHECKER_EXEC="./checker" # <-- CAMBIA ESTO SI ES NECESARIO
# !!! ======================================================== !!!

VALGRIND_OPTS="--leak-check=full --show-leak-kinds=all"
VALGRIND_CMD="valgrind $VALGRIND_OPTS"
MIN_NUM=1
MAX_NUM=1000

# --- Archivos Temporales (nombres fijos) ---
ARGS_FILE_100="test_100.txt"
OPS_FILE_100="ops_100.txt"
ARGS_FILE_500="test_500.txt"
OPS_FILE_500="ops_500.txt"

# Limpiar archivos de ejecuciones anteriores
rm -f $ARGS_FILE_100 $OPS_FILE_100 $ARGS_FILE_500 $OPS_FILE_500

# --- Pruebas ---

echo -e "${YELLOW}=== TEST 100 NÚMEROS (CON VALGRIND) ===${NC}"

# 1. Generar números
echo "Generando 100 nuevos números aleatorios ($MIN_NUM-$MAX_NUM) en $ARGS_FILE_100..."
shuf -i $MIN_NUM-$MAX_NUM -n 100 | tr '\n' ' ' > "$ARGS_FILE_100"
if [ $? -ne 0 ]; then
    echo "${RED}Error: No se pudieron generar los números para $ARGS_FILE_100. Abortando.${NC}"
    exit 1
fi
echo "Números generados."

# 2. Leer argumentos
ARGS_100=$(cat "$ARGS_FILE_100")
echo "Total números: $(echo $ARGS_100 | wc -w)"

# 3. Ejecutar pipeline principal (Valgrind en push_swap, tee, Checker Oficial)
echo -e "\n${CYAN}Ejecutando Valgrind + push_swap | tee | Checker Oficial...${NC}"
# Guardamos la salida del checker oficial por si nos interesa verla
official_checker_output_100=$($VALGRIND_CMD $PUSH_SWAP_EXEC $ARGS_100 | tee "$OPS_FILE_100" | $OFFICIAL_CHECKER_EXEC $ARGS_100)

# 4. Mostrar resultados básicos (del checker oficial y conteo)
echo -e "\n--- Resultados Preliminares Test 100 ---"
echo "Salida Checker_linux: $official_checker_output_100" # Muestra directamente OK o KO
# Contar operaciones, verificando que el archivo existe
op_count_100=0
if [ -f "$OPS_FILE_100" ]; then 
    op_count_100=$(cat "$OPS_FILE_100" | wc -l)
    echo -n "Número de operaciones: ${op_count_100}"
else 
    echo -n "Número de operaciones: ${YELLOW}Archivo no encontrado${NC}"
fi
echo "" # Nueva línea después del conteo

# 5. *** NUEVA SECCIÓN: Comprobar con MI Checker ***
echo -e "\n${CYAN}Comprobando operaciones con Checker Bonus ($MY_CHECKER_EXEC)...${NC}"
# Verificar si el archivo de operaciones existe Y si MI checker es ejecutable
if [ -f "$OPS_FILE_100" ] && [ -x "$MY_CHECKER_EXEC" ]; then
    # Ejecutar MI checker leyendo del archivo de operaciones
    my_checker_output_100=$(cat "$OPS_FILE_100" | $MY_CHECKER_EXEC $ARGS_100 2>/dev/null)
    my_exit_status_100=$?
    # Mostrar resultado de MI checker
    printf "Resultado Checker Bonus  : "
    if [[ "$my_checker_output_100" == "OK" && $my_exit_status_100 -eq 0 ]]; then
        printf "%s[ OK ]%s\n" "${GREEN}" "${NC}"
    else
        printf "%s[ KO ]%s (Salida: '%s', Código: %d)\n" "${RED}" "${NC}" "$my_checker_output_100" "$my_exit_status_100"
    fi
# Manejar casos donde no se puede ejecutar la comprobación
elif [ ! -f "$OPS_FILE_100" ]; then
     echo "${YELLOW}Advertencia: No se puede comprobar con '$MY_CHECKER_EXEC' porque $OPS_FILE_100 no existe.${NC}"
elif [ ! -x "$MY_CHECKER_EXEC" ]; then
     echo "${YELLOW}Advertencia: No se puede comprobar porque '$MY_CHECKER_EXEC' no existe o no es ejecutable.${NC}"
fi
# *** FIN NUEVA SECCIÓN ***

echo "--- (Salida de Valgrind para push_swap mezclada arriba) ---"


echo -e "\n=======================================\n"


# --- Prueba 500 Números ---
echo -e "${YELLOW}=== TEST 500 NÚMEROS (CON VALGRIND) ===${NC}"

# 1. Generar números
echo "Generando 500 nuevos números aleatorios ($MIN_NUM-$MAX_NUM) en $ARGS_FILE_500..."
shuf -i $MIN_NUM-$MAX_NUM -n 500 | tr '\n' ' ' > "$ARGS_FILE_500"
if [ $? -ne 0 ]; then
    echo "${RED}Error: No se pudieron generar los números para $ARGS_FILE_500. Abortando.${NC}"
    exit 1
fi
echo "Números generados."

# 2. Leer argumentos
ARGS_500=$(cat "$ARGS_FILE_500")
echo "Total números: $(echo $ARGS_500 | wc -w)"

# 3. Ejecutar pipeline principal
echo -e "\n${CYAN}Ejecutando Valgrind + push_swap | tee | Checker Oficial...${NC}"
official_checker_output_500=$($VALGRIND_CMD $PUSH_SWAP_EXEC $ARGS_500 | tee "$OPS_FILE_500" | $OFFICIAL_CHECKER_EXEC $ARGS_500)

# 4. Mostrar resultados básicos
echo -e "\n--- Resultados Preliminares Test 500 ---"
echo "Salida Checker_linux: $official_checker_output_500"
op_count_500=0
if [ -f "$OPS_FILE_500" ]; then 
    op_count_500=$(cat "$OPS_FILE_500" | wc -l)
    echo -n "Número de operaciones: ${op_count_500}"
else 
    echo -n "Número de operaciones: ${YELLOW}Archivo no encontrado${NC}"
fi
echo "" # Nueva línea

# 5. *** NUEVA SECCIÓN: Comprobar con MI Checker ***
echo -e "\n${CYAN}Comprobando operaciones con Checker Bonus ($MY_CHECKER_EXEC)...${NC}"
if [ -f "$OPS_FILE_500" ] && [ -x "$MY_CHECKER_EXEC" ]; then
    my_checker_output_500=$(cat "$OPS_FILE_500" | $MY_CHECKER_EXEC $ARGS_500 2>/dev/null)
    my_exit_status_500=$?
    printf "Resultado Checker Bonus : "
    if [[ "$my_checker_output_500" == "OK" && $my_exit_status_500 -eq 0 ]]; then
        printf "%s[ OK ]%s\n" "${GREEN}" "${NC}"
    else
        printf "%s[ KO ]%s (Salida: '%s', Código: %d)\n" "${RED}" "${NC}" "$my_checker_output_500" "$my_exit_status_500"
    fi
elif [ ! -f "$OPS_FILE_500" ]; then
     echo "${YELLOW}Advertencia: No se puede comprobar con '$MY_CHECKER_EXEC' porque $OPS_FILE_500 no existe.${NC}"
elif [ ! -x "$MY_CHECKER_EXEC" ]; then
     echo "${YELLOW}Advertencia: No se puede comprobar porque '$MY_CHECKER_EXEC' no existe o no es ejecutable.${NC}"
fi
# *** FIN NUEVA SECCIÓN ***

echo "--- (Salida de Valgrind para push_swap mezclada arriba) ---"


echo -e "\n${GREEN}=== FIN DE LAS PRUEBAS ===${NC}"

# Limpieza opcional al final
# echo "Limpiando archivos temporales..."
# rm -f $ARGS_FILE_100 $OPS_FILE_100 $ARGS_FILE_500 $OPS_FILE_500

exit 0
EOF
