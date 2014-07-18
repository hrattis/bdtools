#!/bin/bash
DOMAIN=$1
SUBJ="/C=BE/L=Waterloo/O=Mastercard International Incorporated/CN=$1"

echo "Creando CSR..."
openssl req -out $DOMAIN".csr" -new -newkey rsa:2048 -nodes -subj "$SUBJ" -keyout $DOMAIN"_key.pem"

echo "Quitando contraseña a la llave..."
openssl rsa -in $DOMAIN"_key.pem" -out $DOMAIN"_nopass_key.pem"

clear
openssl req -text -noout -verify -in $DOMAIN".csr"
