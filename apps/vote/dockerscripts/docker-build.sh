#!/usr/bin/env bash
set -x -e

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

$cwd/../azure-vote/build.sh
$cwd/../azure-vote-mysql/build.sh
