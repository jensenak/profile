#!/bin/bash
# shellcheck disable=SC1090

tw() {
    terraform workspace select "${1}_$AWS_DEFAULT_REGION"
}

chup() {
    if [[ -z $1 ]]
    then
        cd ..
    else
        p=./
        for (( i=0; i<${#1}; i++ ))
        do
            p=${p}../
        done
        cd "$p" || exit 1
    fi
}

cm() {
    mkdir -p "$1"
    cd "$1" || exit 1
}

venv() {
    b=$(basename "$PWD")
    venv_path=~/virtual_envs/
    if [[ -z $1 ]]
    then
        if [[ -d $venv_path/$b ]]
        then
            source "$venv_path/$b/bin/activate"
        else
            printf "Could not find virtual env for %s\n" "$b"
        fi
    else
        if [[ $1 == "2" || $1 == "3" ]]
        then
            virtualenv -p "python$1" "$venv_path/$b"
            source "${venv_path}$b/bin/activate"
        else
            if [[ -d "$venv_path/$1" ]]
            then
                source "$venv_path/$1/bin/activate"
            fi
        fi
    fi
}

fixhost() {
    if [ -z "$1" ]
    then
        printf "Please specify a line number to delete\n"
        return
    fi
    gsed -i "${1}d" ~/.ssh/known_hosts
}

function dmat() {
  if [[ $1 == "dev" ]]; then
    ACCOUNT_ID=102179876835
    ENV_NAME="dev"
  elif [[ $1 == "int" ]]; then
    ACCOUNT_ID=630855087657
    ENV_NAME="int"
  elif [[ $1 == "prod" ]]; then
    ACCOUNT_ID=625621840120
    ENV_NAME="prod"
  fi
  if [[ $2 == "cli" || -z $2 ]]; then
    echo "Setting credentials on this environment..."
    # shellcheck disable=SC1091
    doormat aws --role=arn:aws:iam::${ACCOUNT_ID}:role/cloud_${ENV_NAME}-developer | source /dev/stdin
    export AWS_ENV=${ENV_NAME}
  elif [[ $2 == "ui" ]]; then
    doormat aws --role=arn:aws:iam::${ACCOUNT_ID}:role/cloud_${ENV_NAME}-developer --console
  fi
}

#Colorize stderr
# usage: colorize COMMAND [ARGS...]
# colorize()(set -o pipefail; "$@" 2>&1>&3|sed $'s/.*/\e[1;31m&\e[m/'>&2)3>&1

