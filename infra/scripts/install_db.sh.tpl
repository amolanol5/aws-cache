#!/bin/bash

## install mysql client
echo "install packages"
sudo dnf update -y
sudo dnf install mariadb105 -y

## variables
echo "set variables"
export DB_HOST=${DB_HOST}
export DB_ADMIN=${DB_ADMIN}
export DB_PASSWORD=${DB_PASSWORD}


## import sql file
echo "building seed file"
cat <<EOF >>seed.sql
${DB_FILE}
EOF

## install database
echo "create database"
mysql -h $DB_HOST -P 3306 -u $DB_ADMIN -p$DB_PASSWORD < seed.sql

# ## delete instance
echo "terminating instance"
shutdown -h now
