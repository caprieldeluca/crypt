#!/bin/bash

# Función para mostrar el mensaje de uso y salir con un código de error
mostrar_uso() {
    echo "Uso: $0 <fichero_a_encriptar>"
    exit "$1"
}

# Verificar que se proporcionó un argumento
if [ $# -ne 1 ]; then
    echo "Error: La cantidad de argumentos no es igual a uno."
    mostrar_uso 1
fi

FICHERO="$1"

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
    exit 1
fi

# Ejecutar gpg (https://linux.die.net/man/1/gpg)
gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback --passphrase-fd 0 --no-symkey-cache "$FICHERO" <<< "$PASS1"

# Limpiar y eliminar variables
PASS1=""
PASS2=""
unset PASS1 PASS2

