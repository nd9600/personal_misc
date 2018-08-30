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

gco() {
    git checkout "$1"	
}

psr2() {
    vendor/bin/phpcbf --standard=psr2 --report=diff app/
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

function aws_mount_remote {
    sshfs aws:/home/nathan/local ~/aws/remote/
}

container_freetobook() {
    docker exec -it freetobook-docker_php_1 bash
}

container_freetobook_logs() {
    docker exec -it freetobook-docker_php_1 tail -f /var/log/php_error_log
}

container_freetobook_repl() {
    docker exec -it freetobook-docker_php_1 sh -c "cd /var/www && ./vendor/bin/psysh"
}

container_portal() {
    docker exec -it freetobook-docker_php_portal_1 bash
}

container_portal_logs() {
    docker exec -it freetobook-docker_php_portal_1 tail -f /var/www/storage/logs/laravel.log
}

container_redis_flushall() {
    docker exec -it freetobook-docker_redis_portal_1 redis-cli flushall
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
