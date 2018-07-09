#!/usr/bin/env bash

gadd() {
    git add -A .
}

gcommit() {
    git commit -m "$1"
}

gpush() {
    gadd
    gcommit "$1"
    git push
}

gbranch() {
	git checkout -b "$1"
        git push -u # sets the local's branches upstream
}

gshow() {
    re='^[0-9]+$'
    if [[ -z "$1" ]] || (! [[ $1 =~ $re ]])
    then
        git show
    else
        git show HEAD~"$1"
    fi
}

container_freetobook() {
    docker exec -it freetobook-docker_php_1 bash
}

container_freetobook_logs() {
    docker exec -it freetobook-docker_php_1 tail -f /var/log/php_error_log
}

container_portal() {
    docker exec -it freetobook-docker_php_portal_1 bash
}

container_redis_flushall() {
    docker exec -it freetobook-docker_redis_portal_1 redis-cli flushall
}
