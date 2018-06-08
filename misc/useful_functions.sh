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

gcheckout() {
	git checkout -b "$1"
	git push -u
}
