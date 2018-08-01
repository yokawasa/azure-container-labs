#!/bin/sh

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

MYSQL_USER="<mysql user>"
MYSQL_PASSWORD="<mysql password>"
MYSQL_DATABASE="azurevote"  # fixed
MYSQL_HOST="<mysql host>"

version=`cat $cwd/../azure-vote/VERSION`
tag="$version"
echo "tag=$tag"

docker run --rm \
    -e MYSQL_USER=$MYSQL_USER \
    -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -e MYSQL_HOST=$MYSQL_HOST \
    -p 8080:80 -it azure-vote-front:$tag
