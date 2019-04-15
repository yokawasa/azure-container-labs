# Helper: Docker Tips

<!-- TOC -->
- [Helper: Docker Tips](#helper-docker-tips)
  - [docker command: attach and exec](#docker-command-attach-and-exec)
    - [docker attach](#docker-attach)
    - [docker exec](#docker-exec)
  - [docker command: p option and EXPONSE in Dockerfile](#docker-command-p-option-and-exponse-in-dockerfile)
  - [Dockerfile: ENTORYPOINT and CMD](#dockerfile-entorypoint-and-cmd)

## docker command: attach and exec
### docker attach
As described in [docker attach](https://docs.docker.com/engine/reference/commandline/attach/) in docker CLI reference page, `docker attach` attaches your terminal’s standard input, output, and error (or any combination of the three) to a running container using the container’s ID or name. This allows you to view its ongoing output or to control it interactively, as though the commands were running directly in your terminal.

> docker attach [OPTIONS] CONTAINER

Here is example:
```sh
# Check running docker containers
$ docker ps -a

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                           NAMES
250510ca2534        azure-vote-front    "/entrypoint.sh /sta…"   2 weeks ago         Up 2 minutes        443/tcp, 0.0.0.0:8080->80/tcp   azure-vote-front
f01f4cbbbae3        azure-vote-back     "docker-entrypoint.s…"   2 weeks ago         Up 4 minutes        0.0.0.0:3306->3306/tcp          azure-vote-back

# attache to azure-vote-front
$ docker attach azure-vote-front

# send request to service run by azure-vote-front
$ curl localhost:8080

# Then, you'll see the container's output like this:
172.18.0.1 - - [19/Nov/2018:00:59:11 +0000] "GET / HTTP/1.1" 200 967 "-" "curl/7.54.0" "-"
[pid: 16|app: 0|req: 2/2] 172.18.0.1 () {32 vars in 334 bytes} [Mon Nov 19 00:59:11 2018] GET / => generated 967 bytes in 7 msecs (HTTP/1.1 200) 2 headers in 80 bytes (1 switches on core 0)
```
### docker exec

As described in [docker exec](https://docs.docker.com/engine/reference/commandline/exec),
`docker exec` command runs a new command in a running container. The command started using docker exec only runs while the container’s primary process (PID 1) is running, and it is not restarted if the container is restarted.

> docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

Here is an example
```sh
# Check running docker containers
$ docker ps -a

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                           NAMES
250510ca2534        azure-vote-front    "/entrypoint.sh /sta…"   2 weeks ago         Up 2 minutes        443/tcp, 0.0.0.0:8080->80/tcp   azure-vote-front
f01f4cbbbae3        azure-vote-back     "docker-entrypoint.s…"   2 weeks ago         Up 4 minutes        0.0.0.0:3306->3306/tcp          azure-vote-back

# exec /bin/bash in running a azure-vote-front container
$ docker exec -it azure-vote-front /bin/bash

root@250510ca2534:/app# ls
__pycache__  config_file.cfg  main.py  prestart.sh  static  templates  uwsgi.ini
root@250510ca2534:/app# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.9  49944 20296 ?        Ss   00:54   0:00 /usr/bin/python /usr/bin/supervisord
root        11  0.0  0.2  32608  4984 ?        S    00:54   0:00 nginx: master process /usr/sbin/nginx
root        12  0.0  1.5 174740 31932 ?        S    00:54   0:00 /usr/local/bin/uwsgi --ini /etc/uwsgi/uwsgi.ini --die-on-term --need-app
nginx       13  0.0  0.1  33072  3328 ?        S    00:54   0:00 nginx: worker process
root        15  0.0  1.0 174740 21712 ?        S    00:54   0:00 /usr/local/bin/uwsgi --ini /etc/uwsgi/uwsgi.ini --die-on-term --need-app
root        16  0.0  1.2 179612 25980 ?        S    00:54   0:00 /usr/local/bin/uwsgi --ini /etc/uwsgi/uwsgi.ini --die-on-term --need-app
root        17  0.0  0.1  19956  3556 pts/0    Ss   01:02   0:00 /bin/bash
root        30  0.0  0.1  38384  3128 pts/0    R+   01:06   0:00 ps aux
```

## docker command: p option and EXPONSE in Dockerfile

In your Dockerfile, you can use the verb EXPOSE to expose multiple ports.
```
EXPOSE 3000 80 443 22
```
Then, you would like to build an new image based on above Dockerfile.

```sh
$ docker build -t foo:tag .
```

Then, you can use the `-p` to map host port with the container port, as defined in above EXPOSE of Dockerfile.
```
docker run -p 3001:3000 -p 23:22
```

In case you would like to expose a range of continuous ports, you can run docker like this:
```
docker run -it -p 7100-7120:7100-7120/tcp 
```

## Dockerfile: ENTORYPOINT and CMD

- [Docker ENTRYPOINT & CMD: Dockerfile best practices](https://medium.freecodecamp.org/docker-entrypoint-cmd-dockerfile-best-practices-abc591c30e21)

---
[Top](../README.md)
