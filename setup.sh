#!/bin/bash
scriptDir=$( dirname "${BASH_SOURCE[0]}" );
source ${scriptDir}/settings;

addSudo () {
    if [ "${NEED_SUDO}" == true ]; then
        echo "sudo $@";
        return 0;
    fi
    echo "$@";
    return 0;
}

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

    local listVolume=$(addSudo "docker volume ls");
    local createVolume=$(addSudo "docker volume create ${VOLUME_NAME}");
    local build=$(addSudo "docker build -t ${TAG} ${buildArgs} -f ${scriptDir}/Dockerfile ${scriptDir}");

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
        local setPerms=$( \
            addSudo \
            "docker run --rm -it -v ${VOLUME_NAME}:/paper alpine:${ALPINE_TAG} sh -c 'chown -R 1000:1000 /paper'" \
        );
        eval "${setPerms}";
    fi

    if [ "${EULA}" == "true" ] || [ "${EULA}" == "TRUE" ]; then
        printf "\tSetting eula.txt to true\n";
        local setEula=$( \
            addSudo \
            "docker run --rm -it -v ${VOLUME_NAME}:/paper alpine:${ALPINE_TAG} sh -c 'echo eula=true > /paper/eula.txt && chown 1000:1000 /paper/eula.txt'" \
        );
        eval "${setEula}";
    fi

    printf "Building Docker image ...\n";

    ${build};

    return $?
}

build

exit $?