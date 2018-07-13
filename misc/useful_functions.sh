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
    if [[ -z "$1" ]] || (! [[ $1 =~ $re ]]) # checks if the first argument doesn't exist or isn't a number
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

##fzf

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
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

fzfc() {
  #find ~/ | fzf-tmux | xargs "$1" # searches home dir
  fzf-tmux | xargs "$1"
}