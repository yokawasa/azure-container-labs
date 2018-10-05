#!/bin/sh

while true;
do
    curl http://<GATEWAY_URL>/hello
    #curl -H "foo: bar" http://<GATEWAY_URL>/hello
    sleep 1
done

