# Docker image with pyrogue-contol-server for the SMuRF project

## Description

This docker image, named **smurf-pyrogue-control-server** contains pyrogue-control-server for the SMuRF project.

It is based on the smurf-rogue docker image, and contains Rogue (using the smurf's `cryo-det` branch), python 3, EPICS 3.15.5 (the community version), and other necessary packages and tools.

## Source code

The base image is smurf-rogue, which contains the smurf version of rogue and all additional tools.

The pyrogue-control-server source code is checked out for directly from its [github repository](https://github.com/slaclab/pyrogue-control-server), using the latest stable version **R1.3.0**.

## Building the image

The provided script *build_docker.sh* will automatically build the docker image. It will tag the resulting image using the same git tag string (as returned by `git describe --tags --always`).

## How to get the container

To get the most recent version of the docker image, first you will need to install docker in you host OS and be logged in. Then you can pull a copy by running:

```
docker pull jesusvasquez333/smurf-pyrogue-control-server:<TAG>
```

Where **<TAG>** represents the specific tagged version you want to use.

## How to run the container

To run stat the control server, you must first have a copy of your application's pyrogue tarball in your host. Also, your host must have a direct connection to your target FPGA.

If you want to open the GUI of the control server, the you need go some extra steps in order to be able to forward X from the container to the host; and these steps are different depending if you are running the container locally in the host, or via an ssh connection.

If you want to use the control server in server mode, that is, without a GUI, them you can run directly the container, without the extra steps.

Here below you will find an example bash script you can use for running the container in each case:

### Running the container with GUI

#### Locally from the host

```
$ cat run_docker.sh
docker run -ti \
-u $(id -u) \
-e DISPLAY=unix$DISPLAY \
-v "/tmp/.X11-unix:/tmp/.X11-unix" \
-v "/etc/group:/etc/group:ro" \
-v "/etc/passwd:/etc/passwd:ro" \
-v <APP_DIR>:/python \
-e SERVER_ARGS="-t /python/<PYROGUE_TARBAL_NAME> <OTHER_CONTROL_SERVER_ARGS>" \
jesusvasquez333/smurf-pyrogue-control-server:<TAG>
```

#### Remotely via an ssh connection

```
$ cat run_docker.sh
#!/usr/bin/env bash

XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | sudo xauth -f $XAUTH nmerge -
sudo chmod 777 $XAUTH
X11PORT=`echo $DISPLAY | sed 's/^[^:]*:\([^\.]\+\).*/\1/'`
TCPPORT=`expr 6000 + $X11PORT`
sudo ufw allow from 172.17.0.0/16 to any port $TCPPORT proto tcp
DISPLAY=`echo $DISPLAY | sed 's/^[^:]*\(.*\)/172.17.0.1\1/'`

docker run -ti --rm \
-e DISPLAY=$DISPLAY \
-v $XAUTH:$XAUTH \
-e XAUTHORITY=$XAUTH \
-v <APP_DIR>:/python \
-e SERVER_ARGS="-t /python/<PYROGUE_TARBAL_NAME> <OTHER_CONTROL_SERVER_ARGS>" \
jesusvasquez333/smurf-pyrogue-control-server:<TAG>
```
### Running the container without GUI

```
$ cat run_docker.sh
#!/usr/bin/env bash

docker run -ti --rm \
-v <APP_DIR>:/python \
-e SERVER_ARGS="-t /python/<PYROGUE_TARBAL_NAME> -s <OTHER_CONTROL_SERVER_ARGS>" \
jesusvasquez333/smurf-pyrogue-control-server:<TAG>
```

where:
- **TAG** is the tag version of the docker image you want to use,
- **APP_DIR** is the full path to the folder containing your application's pyrogue tarball in your host,
- **PYROGUE_TARBAL_NAME** is the name of your application's pyrogue tarball.
- **OTHER_CONTROL_SERVER_ARGS** are additional argument passed to the control server (like for example your target IP address, the EPICS PV name prefix, etc.).
