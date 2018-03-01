#!/usr/bin/env bash

# Init script for Mumble/Murmur server "mumo.py" script Docker container
# License: Apache-2.0
# Github: https://github.com/goofball222/mumo.git
SCRIPT_VERSION="0.0.1"
# Last updated date: 2018-02-28

set -Eeuo pipefail

if [ "${DEBUG}" == 'true' ];
    then
        set -x
fi

log() {
    echo "$(date -u +%FT$(nmeter -d0 '%3t' | head -n1)) <docker-entrypoint> $*"
}

log "INFO - Script version ${SCRIPT_VERSION}"

BASEDIR="/opt/mumo"
CONFIGDIR=${BASEDIR}/config
LOGDIR=${BASEDIR}/log

MUMO=${BASEDIR}/mumo.py

MUMO_OPTS="${MUMO_OPTS}"

cd ${BASEDIR}

mumo_setup() {

    if [ ! -f /opt/mumo/config/mumo.ini ]
    then
        log "WARN - No mumo.ini found in ${CONFIGDIR}, copying from defaults"

        cp /opt/mumo/mumo.ini-default /opt/mumo/config/mumo.ini

        sed -i 's/mumo.log/\/opt\/mumo\/log\/mumo.log/' /opt/mumo/config/mumo.ini
        sed -i 's/modules\//\/opt\/mumo\/config\/modules\//' /opt/mumo/config/mumo.ini
        sed -i 's/modules-enabled\//\/opt\/mumo\/config\/modules-enabled\//' /opt/mumo/config/mumo.ini

        chmod a+rw /opt/mumo/config/mumo.ini

        cp -r /opt/mumo/modules /opt/mumo/config
        cp -r /opt/mumo/modules-available /opt/mumo/config

        mkdir -p /opt/mumo/config/modules-enabled
        log "WARN - Defaults copied. Edit the mumo.ini file and add modules before restarting the container."
        exit 1;
    else
        log "INFO - Using existing mumo.ini and config found in ${CONFIGDIR}"
    fi

    ln -s /opt/mumo/config/modules-enabled /opt/mumo/modules-enabled

    log "INFO - Ensuring file permissions for mumo user/group - 'chown -R mumo:mumo ${BASEDIR}'"
    chown -R mumo:mumo ${BASEDIR}

    MUMO_OPTS="${MUMO_OPTS} -i ${CONFIGDIR}/mumo.ini"
}

exit_handler() {
    log "INFO - Exit signal received, commencing shutdown"
    pkill -15 -f ${BASEDIR}/mumo.py
    for i in `seq 0 9`;
        do
            [ -z "$(pgrep -f ${BASEDIR}/mumo.py)" ] && break
            # kill it with fire if it hasn't stopped itself after 9 seconds
            [ $i -gt 8 ] && pkill -9 -f ${BASEDIR}/mumo.py || true
            sleep 1
    done
    log "INFO - Shutdown complete. Nothing more to see here. Have a nice day!"
    log "INFO - Exit with status code ${?}"
    exit ${?};
}

# Wait indefinitely on tail until killed
idle_handler() {
    while true
    do
        tail -f /dev/null & wait ${!}
    done
}

trap 'kill ${!}; exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

if [ "$(id -u)" = '0' ];
    then
        log "INFO - Entrypoint running with UID 0 (root)"
        if [ "$(id mumo -u)" != "${PUID}" ] || [ "$(id mumo -g)" != "${PGID}" ];
            then
                log "INFO - Setting custom mumo UID/GID: UID=${PUID}, GID=${PGID}"
                usermod -u ${PUID} mumo && groupmod -g ${PGID} mumo
            else
                log "INFO - UID/GID for mumo are unchanged: UID=${PUID}, GID=${PGID}"
        fi

        if [[ "${@}" == 'mumo' ]];
            then
                mumo_setup
                if [ "${RUNAS_UID0}" == 'true' ];
                    then
                       log "INFO - RUNAS_UID0 = 'true', running mumo as UID 0 (root)"
                       log "WARN - ======================================================================"
                       log "WARN - *** Running app as UID 0 (root) is an insecure configuration ***"
                       log "WARN - ======================================================================"
                       log "EXEC - ${MUMO} ${MUMO_OPTS}"
                       exec 0<&-
                       exec ${MUMO} ${MUMO_OPTS} &
                       idle_handler
                fi

                log "INFO - Use su-exec to drop priveleges and start mumo as UID=${PUID}, GID=${PGID}"
                log "EXEC - su-exec mumo:mumo ${MUMO} ${MUMO_OPTS}"
                exec 0<&-
                exec su-exec mumo:mumo ${MUMO} ${MUMO_OPTS} &
                idle_handler
            else
                log "EXEC - ${@} as UID 0 (root)"
                exec "${@}"
        fi
    else
        log "WARN - Container/entrypoint not started as UID 0 (root)"
        log "WARN - Unable to change permissions or set custom UID/GID if configured"
        log "WARN - Process will be spawned with UID=$(id -u), GID=$(id -g)"
        log "WARN - Depending on permissions requested command may not work"
        if [[ "${@}" == 'mumo' ]];
            then
                mumo_setup
                exec 0<&-
                log "EXEC - ${MUMO} ${MUMO_OPTS}"
                exec ${MUMO} ${MUMO_OPTS} &
                idle_handler
            else
                log "EXEC - ${@}"
                exec "${@}"
        fi
fi

# Script should never make it here, but just in case exit with a generic error code if it does
exit 1;
