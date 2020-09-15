#!/bin/bash

# Shows the environment and remaining duration in minutes for the current doormat session
_show_doormat_info() {
    # This exported var is set by doormat
    if [ -n "$AWS_SESSION_EXPIRATION" ]
    then
        _aws_exp="$((AWS_SESSION_EXPIRATION-$(date +%s)))"
        if [[ "$_aws_exp" -le 0 ]]
        then
            printf "-"
        else
            # AWS_ENV is exported by the shell script commonly aliased "dm" for things like "dm dev ui"
            _env_color "$AWS_ENV($((_aws_exp/60)))"
        fi
    fi
}

# If you're in a directory with .terraform/environment this will show your current workspace
_show_workspace() {
    w="$(cat .terraform/environment 2>/dev/null)"
    _env_color "$w"
}

# Takes an input string and prints it in a color corresponding to the environment (if the string starts with an env name)
_env_color() {
    # Note that the color sequences here are for zsh specifically.
    case "$1" in
        dev*)
            printf "%%F{cyan}%s%%f" "$1"
            ;;
        int*)
            printf "%%F{yellow}%s%%f" "$1"
            ;;
        prod*)
            printf "%%F{red}%s%%f" "$1"
            ;;
        *)
            printf "%s" "$1"
            ;;
    esac
}

