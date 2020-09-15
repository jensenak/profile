#!/bin/bash

clean_profiles() {
    find ~/tmp/ -name 'zshrc*' -type f -delete
}

undo_profile_change() {
    cp ~/.zshrc ~/.zshrc.redo
    cp ~/.zshrc.bak ~/.zshrc
}

# Edits this file, but performs shell check before sourcing it again
edit_profile() {
    if [ "$1" ]
    then
        profileName=$(_retry_profile)
    else
        profileName=$(_copy_profile)
    fi
    _edit_profile "$profileName"
}

list_profiles() {
    if [ -d ~/tmp ]
    then
        ls -1 ~/tmp/zshrc*
    fi
    if [ -f ~/.zshrc.redo ]
    then
        printf ".zshrc.redo exists from a rollback"
    fi
    if [ -f ~/.zshrc.bak ]
    then
        printf ".zshrc.bak exists"
    fi
}

_copy_profile() {
    if [ ! -d ~/tmp ]
    then
        mkdir ~/tmp
    fi
    # profile name contains date and time + .sh for syntax highlighting
    profileName="$HOME/tmp/zshrc-$(date +%Y%m%d%H%M%S).sh"
    cp ~/.zshrc "$profileName"
    printf "%s" "$profileName"
}

_retry_profile() {
    PS3="Select a profile copy to start editing: "
    select profileName in ~/tmp/zshrc*
    do
        printf "%s" "$profileName"
        break
    done
}

_edit_profile() {
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)
    profileName=$1
    if [ ! -e "$profileName" ]
    then
        printf "%s Could not find tmp file '%s' for editing %s" "$RED" "$profileName" "$RESET"
    else
        vi "$profileName"
        existing="$(md5 ~/.zshrc | awk '{ print $4 }')"
        changed="$(md5 "$profileName" | awk '{ print $4 }')"
        if [ "$existing" = "$changed" ]
        then
            printf "%s ## Nothing changed ## %s\n" "$YELLOW" "$RESET"
            return
        fi
        if ! shellcheck -s bash "$profileName"
        then
            printf "%s ## Your edits have introduced errors, not sourcing file ## %s\n" "$RED" "$RESET"
            printf "The following commands may help you:\n lsp -> list profile versions\n retry -> edit a profile version\n undo -> revert to the profile backup \n cleanup -> discard profile versions"
        else
            printf "%s ## Your edits look good, sourcing file ## %s\n" "$GREEN" "$RESET"
            cp ~/.zshrc ~/.zshrc.bak
            cp "$profileName" ~/.zshrc
            # shellcheck disable=SC1090
            source ~/.zshrc
            rm "$profileName"
        fi
    fi
}

