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
    git push -u --no-verify # sets the local's branches upstream
}

gco() {
    git checkout "$1"
}

gpull() {
    rm .git/refs/remotes/origin/*
    git fetch
    git pull
}

gshow() {
    re='^[0-9]+$'
    if [[ -z "$1" ]] || (! [[ $1 =~ $re ]]) # checks if the first argument doesn't exist or isn't a number
    then
        git show
    else
        git show HEAD~"$1"
    fi
}

gupdateandmerge() {
    branchToMergeWith="$1"
    currentBranch=$(git rev-parse --abbrev-ref HEAD)
    git checkout "$branchToMergeWith"
    git pull
    git checkout "$currentBranch"
    git merge "$branchToMergeWith"
}

psr2() {
    vendor/bin/phpcbf --standard=psr2 --report=diff app/
}

aws_mount_remote() {
    sshfs aws:/home/ubuntu/local ~/aws/remote/
}

docker_up() {
    c=freetobook-docker_db_1
    if [ "$(docker ps -q -f name=freetobookdocker_db_1)" ]; then
      c=freetobookdocker_db_1
    fi

    # brackets make it run in a subshell
    (cd ~/repos/freetobook-docker/ && docker-compose up -d && docker exec -it $c mysql -pchangeme --execute="SET GLOBAL sql_mode=''")
}

docker_down() {
    (cd ~/repos/freetobook-docker/ && docker-compose down)
}

docker_db_fix() {
    c=freetobook-docker_db_1
    if [ "$(docker ps -q -f name=freetobookdocker_db_1)" ]; then
      c=freetobookdocker_db_1
    fi
    docker exec -it $c mysql -pchangeme --execute="SET GLOBAL sql_mode=''"
}

container_freetobook() {
    c=freetobook-docker_php_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_1)" ]; then
      c=freetobookdocker_php_1
    fi
    docker exec -it $c bash -ic "cd /var/www; exec '${SHELL:-sh}'"
}

container_freetobook_logs() {
    c=freetobook-docker_php_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_1)" ]; then
      c=freetobookdocker_php_1
    fi
    docker exec -it $c tail -f /var/log/php_error_log
}

container_freetobook_repl() {
    c=freetobook-docker_php_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_1)" ]; then
      c=freetobookdocker_php_1
    fi
    docker exec -it $c bash -ic "cd /var/www && ./vendor/bin/psysh"
}

container_portal() {
    c=freetobook-docker_php_portal_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_portal_1)" ]; then
      c=freetobookdocker_php_portal_1
    fi
    docker exec -it $c bash -i
}

container_portal_logs() {
    c=freetobook-docker_php_portal_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_portal_1)" ]; then
      c=freetobookdocker_php_portal_1
    fi
    docker exec -it $c tail -f /var/www/storage/logs/laravel.log
}

container_redis_flushall() {
    c=freetobook-docker_redis_portal_1
    if [ "$(docker ps -q -f name=freetobookdocker_redis_portal_1)" ]; then
      c=freetobookdocker_redis_portal_1
    fi
    docker exec -it $c redis-cli flushall
}

##fzf

# makes fzf ignore .git and .gitignore patterns by default
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
            -o -type d -print 2> /dev/null \
        | awk '!/node_modules/ && !/app\/build/' \
        | fzf +m) &&
  cd "$dir"
}

fzfc() {
  #find ~/ | fzf-tmux | xargs "$1" # searches home dir
  fzf-tmux | xargs "$1"
}
