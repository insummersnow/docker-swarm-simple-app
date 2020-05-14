#!/bin/sh

set -a
. ./.env
set +a

. ./.env

CMD=$1
SCALE=$2

build() {
    rm -f ./spring-boot/build/libs/*
    cd spring-boot
    ./gradlew bootJar
    docker-compose.exe -f ../docker-compose_build.yml build
}

start() {
    docker.exe stack deploy -c docker-compose_start.yml ${PREFIX_APP_NAME}
    docker.exe stack ps ${PREFIX_APP_NAME}
}

stop() {
    docker.exe stack rm ${PREFIX_APP_NAME}
}

deploy() {
    docker.exe service update \
    --update-parallelism 2 \
    --update-delay 30s \
    --update-order start-first \
    --image kakao_spring-boot:${VERSION} \
    ${PREFIX_APP_NAME}_spring-boot
}

scale() {
    docker.exe service scale ${PREFIX_APP_NAME}_spring-boot=${SCALE}
}

case "${CMD}" in
    build)
    build
    ;;
    start)
    start
    ;;
    stop)
    stop
    ;;
    restart)
    stop
    sleep 5s
    start
    ;;
    deploy)
    deploy
    ;;
    scale)
    scale
    ;;
    *)
        echo "Usage: ./devops.sh {build|start|stop|restart|deploy|scale}"
        exit 1
    ;;
esac

exit $RETVAL
