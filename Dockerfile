ARG alpineTag

FROM alpine:${alpineTag}

ARG version
ARG build
ARG javaVersion
ARG port
ARG ram
ARG volumeName
ARG uid=1000
ARG gid=${uid}
ARG appDIR=/app

RUN mkdir -p ${appDIR} /${volumeName} \
    && chown -R ${uid}:${gid} ${appDIR} \
    && chown -R ${uid}:${gid} /${volumeName}
RUN apk add bash vim openjdk${javaVersion}-jre

RUN adduser paper -u ${uid} -s /bin/bash -D
USER paper


ADD --chown=paper https://api.papermc.io/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar /app/paper.jar
COPY --chown=paper entrypoint.sh ${appDIR}/
COPY --chown=paper maintainers_configs/ /app/maintainers_configs/

EXPOSE ${port}

ENV PORT=${port}
ENV RAM=${ram}

ENV ENTRYPOINT=${appDIR}/entrypoint.sh

WORKDIR /${volumeName}
ENTRYPOINT [ "bash" , "-c" ,  "${ENTRYPOINT}" ]
