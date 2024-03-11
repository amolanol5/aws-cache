#!/bin/bash

# Nombre de tu aplicación 
APP_NAME="lambda_function_payload.zip"

# Directorio de trabajo
APP_DIR="custom_build_zip"
mkdir -p "$APP_DIR"

# Copiar los archivos de tu aplicación  al directorio
cp -r src/* "$APP_DIR/"

# Instalar las dependencias de  en el directorio de la aplicación
pip3 install -r "$APP_DIR/requirements.txt" -t "$APP_DIR/"

# Empaquetar la aplicación en un archivo ZIP
cd "$APP_DIR"
zip -r ../$APP_NAME .
rm -rf ../$APP_DIR