#!/bin/bash
scriptDir=$( dirname "${BASH_SOURCE[0]}" );
source ${scriptDir}/common.sh;

build () {
    local buildArgs="\
    --build-arg alpineTag=${ALPINE_TAG} \
    --build-arg version=${VERSION} \
    --build-arg build=${BUILD} \
    --build-arg javaVersion=${JAVA_VERSION} \
    --build-arg port=${PORT} \
    --build-arg ram=${RAM} \
    --build-arg volumeName=${VOLUME_NAME} \
    ";

    printf "Building Docker image ...\n";
    $(addSudo) docker build -t ${TAG} ${buildArgs} -f ${scriptDir}/Dockerfile ${scriptDir};

    local listVolume="$(addSudo) docker volume ls";
    local createVolume="$(addSudo) docker volume create ${VOLUME_NAME}";
    local dockerRun="$(addSudo) docker run  --user root --entrypoint bash \
        --rm -it -v ${VOLUME_NAME}:/paper ${TAG} -c";

    volume=$(${listVolume});
    grep -q ${VOLUME_NAME} <<< ${volume};
    if [ $? -ne 0 ]; then
        printf \
            "\tCreating paper Docker volume called %s. This is where all your configs and world data will be." \
            ${VOLUME_NAME};

        ${createVolume};
        if [ $? -ne 0 ]; then
            echo "Volume creation failed!";
            exit 1
        fi
    fi

    if [ "${EULA}" == "true" ] || [ "${EULA}" == "TRUE" ]; then
        printf "\tSetting eula.txt to true\n";
            eval "${dockerRun} 'echo eula=true > /paper/eula.txt'";
    fi


    if [ "${USE_MAINTAINER_CONFIGS}" == "true" ] || [ "${USE_MAINTAINER_CONFIGS}" == "TRUE" ]; then
        printf "\tCopying the repo maintainer's configs for paper and plugins.\n\tI hope you know what you are doing ;)\n";
        eval "${dockerRun} 'cp -av /app/maintainers_configs/* /paper/'";
    fi

    dynmapURL="https://mediafilez.forgecdn.net/files/4167/109/Dynmap-3.5-beta-1-spigot.jar"
    echo "Downloading dynmap plugin. This will go into the volume.";
    eval "${dockerRun} 'mkdir -p /paper/plugins'";
    eval "${dockerRun} 'cd /paper/plugins && wget ${dynmapURL}'";
    eval "${dockerRun} 'chown -R paper:paper /paper'";
}

build

exit $?