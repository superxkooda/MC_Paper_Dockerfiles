#!/bin/bash

scriptDir=$( dirname "${BASH_SOURCE[0]}" );
source ${scriptDir}/common.sh;

confName="${NAME}-configurer"

running=$(addSudo docker ps -f name="^${confName}$");

[ "${running}" ] && \
    echo "${confName} already running, check your terminals for an already running instance." && \
    exit 1;

$(addSudo) docker run --entrypoint bash --rm -it --name ${confName} \
    -v ${VOLUME_NAME}:/${VOLUME_NAME} ${NAME}:${VERSION}; 

exit $?