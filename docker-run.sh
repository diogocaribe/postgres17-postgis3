#!/bin/sh

msg_usage='Usage: docker-run.sh --<option>\n\nOptions: \n\t--local (local development)\n\t--server (dev/stag/prod server)\n'

if [ $# -ne 1 ]; then
    echo ${msg_usage}
    exit 1
else
    case "$1" in
        --local) compose_file='compose.yml'
            ;;
        --server) compose_file='compose.server.yml'
            ;;
        --*) echo "bad option: '$1'\n"
            ;;
        *) echo "bad option: '$1'\n"
            ;;
    esac

    if [ -z ${compose_file+x} ]; then
        echo ${msg_usage}
    else
        if [ ! -f ".env" ]; then
            echo "ERROR: File not found 'docker.env'. Exiting..."
            exit 1
        fi

        . ./.env 
        export $(grep --regexp ^[A-Z] .env | cut -d= -f1)
        docker network ls | grep ${NETWORK} || docker network create ${NETWORK}
        docker ps -q --filter "name=${CONTAINER_NAME}" | xargs -r docker stop
        docker ps -aq --filter "name=${CONTAINER_NAME}" | xargs -r docker rm -f
        docker compose --env-file .env --file ${compose_file} --compatibility up --detach --force-recreate --build --remove-orphans
    fi
fi

exit 0