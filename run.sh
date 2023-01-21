#!/bin/bash
scriptDir=$( dirname "${BASH_SOURCE[0]}" );
source ${scriptDir}/settings;

# Use -d as the arg to run detached.
mode=${1:-""}

docker run --rm -it ${mode} --name ${NAME} -p ${PORT}:${PORT} \
    -v ${VOLUME_NAME}:/${VOLUME_NAME} ${NAME}:${VERSION}; 