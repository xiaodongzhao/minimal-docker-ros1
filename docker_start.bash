#!/bin/bash

USER_ID="$(id -u)"

XSOCK=/tmp/.X11-unix
XAUTH=$HOME/.Xauthority

if [ "$#" -eq 0 ]; then
    HOST_DIR=$(dirname $(readlink -f "$0"))
else
    HOST_DIR=$(dirname $(readlink -f "$1"))
fi
echo "Mounting host dir $HOST_DIR"

DOCKER_DIR=/home/ros/ws

RUNTIME="--gpus all"

VOLUMES="--volume=$XSOCK:$XSOCK:rw
         --volume=$XAUTH:$XAUTH:rw
         --volume=$HOST_DIR:$DOCKER_DIR:rw"

docker run \
    -it --rm \
    $VOLUMES \
    --env="XAUTHORITY=${XAUTH}" \
    --env="DISPLAY=${DISPLAY}" \
    --env="USER_ID=$USER_ID" \
    --privileged \
    --net=host \
    $RUNTIME \
    ros1-dev:melodic
