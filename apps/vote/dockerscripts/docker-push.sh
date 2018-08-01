#!/usr/bin/env bash
set -x -e

if [ $# -ne 2 ]
then
    echo "$0 [dockerhub account] [dockerhub password]"
    exit
fi
echo "docker account name=$1"
echo "docker account passwd=$2"

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

{
docker login -u "$1" -p "$2"

echo "push azure-vote-front....."
version=`cat $cwd/../azure-vote/VERSION`
tag="$version"
echo "tag=$tag"
docker tag azure-vote-front:$tag "$1"/azure-vote-front:$tag
docker push "$1"/azure-vote-front:$tag

echo "push azure-vote-back....."
version=`cat $cwd/../azure-vote-mysql/VERSION`
tag="$version"
echo "tag=$tag"
docker tag azure-vote-back:$tag "$1"/azure-vote-back:$tag
docker push "$1"/azure-vote-back:$tag

docker logout
} 2>&1 | tee push.log
