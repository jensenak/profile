#!/bin/bash

export hcr=git@github.com:hashicorp

pullall() {
    PWDsave=$PWD
    if [ -n "$1" ]
    then
        cd "$1" || exit 1
    fi
    for dir in *
    do
        if [ -d "$dir" ]
        then
            cd "$dir" || exit 1
            git pull
            cd .. || exit 1
        fi
    done
    cd "$PWDsave" || exit 1
}

gitBranchClean() {
    git branch --merged | grep -E -v "(^\*|master)" | xargs git branch -d
}

gitpulldirs() {
    find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree="$PWD"/{} pull \;
}

gitpullall() {
    START=$(git symbolic-ref --short -q HEAD);
    for branch in $(git branch | sed 's/^.//'); do
        git checkout "$branch"
        git pull "${1:-origin}" "$branch" || break
    done
    git checkout "$START"
}

