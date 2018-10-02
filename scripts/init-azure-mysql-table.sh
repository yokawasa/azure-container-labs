#!/bin/sh

MYSQL_USER="<mysql-user>"
MYSQL_PASSWORD="<mysql-password>"
MYSQL_HOST="<mysql-host>"
MYSQL_DB="<mysql-db>"
MYSQL_QUERY="DROP TABLE IF EXISTS azurevote; CREATE TABLE azurevote (voteid INT NOT NULL AUTO_INCREMENT,votevalue VARCHAR(45) NULL,PRIMARY KEY (voteid));"
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never --\
    bash -ic "mysql -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASSWORD $MYSQL_DB -e\"$MYSQL_QUERY\""
