#!/bin/bash
scriptDir=$( dirname "${BASH_SOURCE[0]}" );
source ${scriptDir}/common.sh;

# Use -d as the arg to run detached.
mode=${1:-""}

$(addSudo) docker run --rm -it ${mode} --name ${NAME} -p ${PORT}:${PORT} -p ${MAP_PORT} \
    -v ${VOLUME_NAME}:/${VOLUME_NAME} ${NAME}:${VERSION}; 