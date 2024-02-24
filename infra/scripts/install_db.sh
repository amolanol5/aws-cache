#!/bin/bash

## install mysql client
sudo dnf update -y
sudo dnf install mariadb105 -y

## variables
export DB_HOST=${DB_HOST}
export DB_ADMIN=${DB_ADMIN}
export DB_FILE=${DB_FILE}
export DB_PASSWORD=${DB_PASSWORD}

## import sql file
cat <<EOF >>seed.sql
${DB_FILE}
EOF

## install database
mysql -h $DB_HOST -P 3306 -u $DB_ADMIN -p$DB_PASSWORD < seed.sql

## delete instance
shutdown -h now