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
	# checks out a new branch and pushes it to the remote
	
    git checkout -b "$1"
    git push -u --no-verify # sets the local's branches upstream
}

gco() {
    git checkout "$1"
}

gpull() {
	# resets all the references to the remote so your repo is up to date
    rm .git/refs/remotes/origin/*
    git fetch
    git pull
}

gshow() {
	# shows a specific commit
	# gshow = show most recent commit
	# gshow 1 = show 2nd most recent commit
	# gshow 2 = show 3rd most recent commit
	# ...
	
    re='^[0-9]+$'
    if [[ -z "$1" ]] || (! [[ $1 =~ $re ]]) # checks if the first argument doesn't exist or isn't a number
    then
        git show
    else
        git show HEAD~"$1"
    fi
}

gupdateandmerge() {
	# switches to the branch from the first arg, pulls it, switches back to the original branch, and merges in the first argument
	
    branchToMergeWith="$1"
    currentBranch=$(git rev-parse --abbrev-ref HEAD)
    git checkout "$branchToMergeWith"
    git pull
    git checkout "$currentBranch"
    git merge "$branchToMergeWith"
}

gmergeto() {
	# merges this branch (if 2nd arg, push changes with msg from 2nd arg) into 1st argument, and if no merge conflicts, pushes, then switches back to original branch
	
    branchToMergeWith="$1"
    msg="$2"
    currentBranch=$(git rev-parse --abbrev-ref HEAD)

	if [[ -z "$2" ]]
	then
		git pull
	else
		gadd
		gcommit "$msg"
		
		git pull
		git push
	fi

    git checkout "$branchToMergeWith"
    git pull
    git merge --no-ff "$currentBranch"
    numberOfMergeConflicts=$(expr $(git diff --check | wc -l) / 3) # there are 3 markers per conflict

    if [ "$numberOfMergeConflicts" -eq 0 ]
    then
        git push
        git checkout "$currentBranch"
    else
        if [ "$numberOfMergeConflicts" -eq 1 ]
        then
            echo "fix merge conflict before pushing"
        else
            echo "fix ${numberOfMergeConflicts} merge conflicts before pushing"
        fi
    fi
}

gcleanupbranches() {
	# removes any branches locally that have been deleted from the remote - will remove master if you're not on it when you run the command
	
    git fetch -p
    git branch --merged master --no-color | grep -v '^* master$' | xargs -n1 -r git branch -d
    git pull
}

psr2() {
	# runs psr2 checks and fixes, and commits changes
    vendor/bin/phpcbf --standard=psr2 --report=diff app/
    gpush "psr2"
}

docker_up() {
	# starts docker containers
	
    c=freetobook-docker_db_1
    if [ "$(docker ps -q -f name=freetobookdocker_db_1)" ]; then
      c=freetobookdocker_db_1
    fi

    if service apache2 status | grep -q "(running)"; then
      sudo service apache2 stop
    fi

    # brackets make it run in a subshell
    (cd ~/repos/freetobook-docker/ && docker-compose up -d && docker exec -it $c mysql -u root -pchangeme --execute="SET GLOBAL sql_mode=''")
}

docker_down() {
	# stops docker containers
	
    (cd ~/repos/freetobook-docker/ && docker-compose down)
}

docker_db_fix() {
	# fixes annoying docker error
	
    c=freetobook-docker_db_1
    if [ "$(docker ps -q -f name=freetobookdocker_db_1)" ]; then
      c=freetobookdocker_db_1
    fi
    docker exec -it $c mysql -pchangeme --execute="SET GLOBAL sql_mode=''"
}

container_freetobook() {
	# switches to FTB docker container
	
    c=freetobook-docker_php_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_1)" ]; then
      c=freetobookdocker_php_1
    fi
    docker exec -it $c bash -ic "cd /var/www; exec '${SHELL:-sh}'"
}

container_freetobook_logs() {
	# displays updating logs from FTB
	
    c=freetobook-docker_php_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_1)" ]; then
      c=freetobookdocker_php_1
    fi
    docker exec -it $c tail -f /var/log/php_error_log
}

container_freetobook_repl() {
	# opens a REPL in FTB
	
    c=freetobook-docker_php_1
    if [ "$(docker ps -q -f name=freetobookdocker_php_1)" ]; then
      c=freetobookdocker_php_1
    fi
    docker exec -it $c bash -ic "cd /var/www && ./vendor/bin/psysh"
}

container_portal() {
	# switches to Portal docker container - for a REPL, just run `php artisan tinker`
	
    c=freetobook-docker_portal_1
    if [ "$(docker ps -q -f name=freetobookdocker_portal_1)" ]; then
      c=freetobookdocker_portal_1
    fi
    docker exec -it $c bash -i
}

container_portal_logs() {
	# displays updating logs from Portal
	
    c=freetobook-docker_portal_1
    if [ "$(docker ps -q -f name=freetobookdocker_portal_1)" ]; then
      c=freetobookdocker_portal_1
    fi
    docker exec -it $c tail -f /var/www/storage/logs/laravel.log
}

container_redis_flushall() {
	# flushes Redis cache; needed when you change rates/property info etc. on FTB and want Portal to update
	
    c=freetobook-docker_redis_portal_1
    if [ "$(docker ps -q -f name=freetobookdocker_redis_portal_1)" ]; then
      c=freetobookdocker_redis_portal_1
    fi
    docker exec -it $c redis-cli flushall
}

container_messenger() {
	# switches to Messenger docker container - for a REPL, just run `php artisan tinker`
	
    c=freetobook-docker_php-messenger_1
    if [ "$(docker ps -q -f name=freetobookdocker_php-messenger_1)" ]; then
      c=freetobookdocker_php-messenger_1
    fi
    docker exec -it $c bash -ic "cd /var/www; exec '${SHELL:-sh}'"
}

container_messenger_logs() {
	# displays updating logs from Messenger
	
    c=freetobook-docker_php-messenger_1
    if [ "$(docker ps -q -f name=freetobookdocker_php-messenger_1)" ]; then
      c=freetobookdocker_php-messenger_1
    fi
    docker exec -it $c tail -f /var/www/storage/logs/laravel.log
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
