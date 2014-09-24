#!/bin/bash
set -e

# Tunable settings
PORT=${PORT:-80}
USER=${USER:-daemon}
LISTEN_ADDRESS=${LISTEN_ADDRESS:-"0.0.0.0"}
HTTP_USER=${HTTP_USER:-anonymous}
HTTP_PASS=${HTTP_PASS:-`date | md5sum | head -c10`}

# Misc settings
ERR_LOG=/log/$HOSTNAME/clarity_stderr.log
CLARITY_BIN=/usr/local/bin

if [ -e /config/clarity.yml ]; then
    CONFIG=/config/clarity.yml
fi

restart_message() {
    echo "Container restart on $(date)."
    echo -e "\nContainer restart on $(date)." | tee -a $ERR_LOG
}

normal_start() {
    echo ""
    exec $CLARITY_BIN/clarity \
        -p $PORT \
        --address=$LISTEN_ADDRESS \
        --user=$USER \
        --username=$HTTP_USER \
        --password=$HTTP_PASS \
        /log
}

if [ ! -e /tmp/clarity_first_run ]; then
    touch /tmp/clarity_first_run

    echo "HTTP Info:" | tee -a $ERR_LOG
    echo "  Username: $HTTP_USER" | tee -a $ERR_LOG
    echo "  Password: $HTTP_PASS" | tee -a $ERR_LOG

    # docker run arguments > config file > default start with env settings
    if [ $# -le 1 ]; then
        if [ -z ${CONFIG} ]; then
            normal_start
        else
            exec $CLARITY_BIN/clarity \
                -c $CONFIG \
                /log
        fi
    else
        exec $CLARITY_BIN/clarity "$@"
    fi
else
    restart_message
    normal_start
fi
