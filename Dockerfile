FROM alpine:3.18
MAINTAINER Pascal Zimmermann <ZPascal>

LABEL application="Alpine Linux (with the forked OIDC Gatekeeper)" \
      description="Base Linux Container Image for Gatekeeper Proxy" \
      version="1.4.0" \
      lastUpdatedBy="Pascal Zimmermann" \
      lastUpdatedOn="2023-09-19"

ARG FILEBEAT_VERSION="8.9.1"

ENV APP_NAME="gatekeeper" \
    APP_VERSION="2.7.0" \
    GOOS="linux" \
    GOARCH="amd64" \
    OIDC_DISCOVERY_URL="" \
    OIDC_CLIENT_ID="" \
    OIDC_CLIENT_SECRET="" \
    OIDC_LISTEN_URL="" \
    OIDC_ENCRYPTION_KEY="" \
    OIDC_REDIRECTION_KEY="" \
    OIDC_UPSTREAM_URL="" \
    IMAGE_NAME="alpine-3.18-gatekeeper" \
    IMAGE_VERSION="1.4.0" \
    IMAGE_APP_DIR="/image/app" \
    IMAGE_BACKUP_CRON="2 1 * * *" \
    IMAGE_BACKUP_DIR="/image/backup" \
    IMAGE_BACKUP_ENABLED="1" \
    IMAGE_BACKUP_LOG="/storage/logs/backup.log" \
    IMAGE_BACKUP_RETENTION="3" \
    IMAGE_BACKUP_SCRIPTS_DIR="/image/backup/scripts" \
    IMAGE_BASE_DIR="/image" \
    IMAGE_CONFIG_DIR="/image/config" \
    IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CRON_ENABLED="1" \
    IMAGE_HEALTH_LIVENESS_CHECK_ENABLED="true" \
    IMAGE_HEALTH_READINESS_FORCE_REBOOT="true" \
    IMAGE_HEALTH_CRON="*/5 * * * *" \
    IMAGE_HEALTH_DIR="/image/health" \
    IMAGE_HEALTH_LIVENESS_DIR="/image/health/liveness.probes.d" \
    IMAGE_HEALTH_READINESS_DIR="/image/health/readiness.probes.d" \
    IMAGE_HEALTH_LIVENESS_LOG="/storage/logs/liveness.log" \
    IMAGE_HEALTH_READINESS_LOG="/storage/logs/readiness.log" \
    IMAGE_LOGGING_DIR="/image/logging" \
    IMAGE_LOGROTATE_CRON="32 4 * * *" \
    IMAGE_RESTORE_DIR="/image/restore" \
    IMAGE_RESTORE_SCRIPTS_DIR="/image/restore/scripts" \
    IMAGE_SECRETS_DIR="/image/secrets" \
    IMAGE_SETUP_RUNALWAYS_DIR="/image/setup/run.always" \
    IMAGE_SETUP_RUNONCE_DIR="/image/setup/run.once" \
    IMAGE_SUPERVISOR_DIR="/image/supervisord" \
    LOGGING_REDIS_HOST="" \
    LOGGING_REDIS_PASSWORD="" \
    PROCESS_PID_DIR="/tmp" \
    PROCESS_STATE_DIR="/tmp" \
    STORAGE_BACKUP_DIR="/storage/backup" \
    STORAGE_BASE_DIR="/storage" \
    STORAGE_CONF_DIR="/storage/conf" \
    STORAGE_DATA_DIR="/storage/data" \
    STORAGE_FILEBEAT_DIR="/storage/filebeat" \
    STORAGE_FILEBEAT_REG_DIR="/storage/filebeat_reg" \
    STORAGE_LOGS_DIR="/storage/logs" \
    SUPERVISOR_LOGS_DIR="/storage/logs/supervisor" \
    TZ="Europe/Berlin"

VOLUME ["$STORAGE_BASE_DIR"]

ADD /docker/files /

RUN addgroup -S -g 500 kubernetes && \
    adduser -S -u 500 -G kubernetes -h /home/kubernetes kubernetes && \
    echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "@edge-testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@edge-community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add tzdata logrotate rsync curl py3-pip ca-certificates libc6-compat wget && \
    wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz  && \
    tar xzvf filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz && \
    mv filebeat-${FILEBEAT_VERSION}-linux-x86_64/filebeat /usr/bin/filebeat && \
    rm -rf filebeat-${FILEBEAT_VERSION}-linux-x86_64 && \
    rm filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz && \
    pip install crontab supervisor requests && \
    chown -R kubernetes:kubernetes $IMAGE_BASE_DIR && \
    find $IMAGE_BASE_DIR -name "*.py" -exec chmod +x "{}" ';' && \
    chmod +x /run.py && \
    chmod +x $IMAGE_CRON_DIR/cron.py && \
    chmod +x $IMAGE_SUPERVISOR_DIR/eventlistener.py && \
    rm -rf /var/cache/apk/* && \
    cd /home/kubernetes && \
    wget "https://github.com/gogatekeeper/${APP_NAME}/releases/download/${APP_VERSION}/${APP_NAME}_${APP_VERSION}_${GOOS}_${GOARCH}.tar.gz" && \
    tar xfz "${APP_NAME}_${APP_VERSION}_${GOOS}_${GOARCH}.tar.gz" && rm "${APP_NAME}_${APP_VERSION}_${GOOS}_${GOARCH}.tar.gz" && \
    mv /home/kubernetes/${APP_NAME}_${APP_VERSION}_${GOOS}_${GOARCH}/${APP_NAME} /usr/bin && \
    rm -rf /home/kubernetes/${APP_NAME}_${APP_VERSION}_${GOOS}_${GOARCH} && \
    chmod +x /usr/bin/${APP_NAME} && chown 0:0 /usr/bin/${APP_NAME} && \
    chown -R 500:500 $IMAGE_BASE_DIR && find $IMAGE_BASE_DIR -name "*.py" -exec chmod +x "{}" ';'

ENTRYPOINT ["/run.py"]

USER 500

EXPOSE 3000
