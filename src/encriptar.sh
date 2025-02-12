#!/bin/bash

# Función para mostrar el uso y salir con un código de error
mostrar_uso() {
    echo "Uso: $0 [-p] <fichero_a_encriptar>"
    exit "$1"
}

# Variables
PRESERVAR=false

# Parsear los argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            PRESERVAR=true
            shift
            ;;
        -*)
            echo "Error: Opción desconocida $1"
            mostrar_uso 1
            ;;
        *)
            if [ -z "$FICHERO" ]; then
                FICHERO="$1"
            else
                echo "Error: Se proporcionaron múltiples archivos."
                mostrar_uso 1
            fi
            shift
            ;;
    esac
done

# Verificar que se proporcionó un archivo
if [ -z "$FICHERO" ]; then
    echo "Error: No se proporcionó un archivo a encriptar."
    mostrar_uso 1
fi

# Verificar si el fichero existe y es un fichero regular
if [ ! -f "$FICHERO" ]; then
    echo "Error: El fichero '$FICHERO' no existe o no es un fichero válido."
    mostrar_uso 2
fi

# Pedir la passphrase dos veces
read -s -p "Introduce la passphrase: " PASS1 && echo
read -s -p "Repite la passphrase: " PASS2 && echo

# Verificar que ambas passphrases coincidan
if [ "$PASS1" != "$PASS2" ]; then
    echo "Error: Las passphrases no coinciden."
    exit 3
fi

# Ejecutar gpg con cifrado simétrico
gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback --passphrase-fd 0 --no-symkey-cache "$FICHERO" <<< "$PASS1"

# Si no se pasó -p, eliminar el archivo de forma segura
if [ "$PRESERVAR" = false ]; then
    shred -u -z -n 3 "$FICHERO"
    echo "El fichero '$FICHERO' ha sido eliminado de forma segura."
else
    echo "El fichero '$FICHERO' se ha preservado."
fi

# Limpiar y eliminar variables
PASS1=""
PASS2=""
unset PASS1 PASS2

