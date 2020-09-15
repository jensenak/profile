#!/bin/bash

ecsami() {
    printf "%s" "$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux/recommended | python -c 'import sys, json; json.dump(json.loads(json.load(sys.stdin)["Parameters"][0]["Value"])["image_id"], sys.stdout)')"
}

aws_profile() {
    if [ -z "$1" ]
    then
        printf "Unsetting profile\nAvailable profiles are:\n"
        grep -oP '(?<=profile )(\w+)' ~/.aws/config
    fi
    export AWS_PROFILE="$1"
}

aws_region() {
    if [ -z "$1" ]
    then
        printf "Using default region for your profile\n"
        unset AWS_DEFAULT_REGION
    else
        export AWS_DEFAULT_REGION="$1"
    fi
}

