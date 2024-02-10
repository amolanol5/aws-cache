#!/bin/bash

# Nombre de tu aplicación 
APP_NAME="lambda_function_payload"

# Directorio de trabajo
APP_DIR="custom_build_zip"
mkdir -p "$APP_DIR"

# Copiar los archivos de tu aplicación  al directorio
cp -r src/* "$APP_DIR/"

# Instalar las dependencias de  en el directorio de la aplicación
pip3 install -r "$APP_DIR/requirements.txt" -t "$APP_DIR/"

# Empaquetar la aplicación en un archivo ZIP
ZIP_FILE="$APP_NAME.zip"
zip -r "$ZIP_FILE" $APP_DIR/*

# Actualizar la función Lambda de AWS con el archivo ZIP
LAMBDA_FUNCTION_NAME="nombre_de_tu_funcion_lambda"
AWS_REGION="us-east-1"  # Cambia esto al código de tu región

# aws lambda update-function-code --function-name "$LAMBDA_FUNCTION_NAME" --zip-file "fileb://$ZIP_FILE" --region "$AWS_REGION"

# Limpiar el directorio de trabajo temporal
# rm -rf "$WORK_DIR"
# echo "Script completado"

rm -rf $APP_DIR