#!/bin/sh
set -e -x

MYSQL_USER="<mysql-user>"
MYSQL_PASSWORD="<mysql-password>"
MYSQL_HOST="<mysql-host>"
MYSQL_DB="<mysql-db>"
kubectl run -it --rm --image=mysql:5.7 mysql-client -- mysql -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASSWORD $MYSQL_DB
