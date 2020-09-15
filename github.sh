#!/bin/bash

github() {
    url="$(git config --get remote.origin.url 2>/dev/null)"
    if [ -n "$url" ]
    then
        start=0
        end=-1
        if [ "${url[0,4]}" = "git@" ]
        then
            start=5
        fi
        if [ "${url[-4,-1]}" = ".git" ]
        then
            end=-5
        fi
        url="${url[$start,$end]//://}"
        if [ "${url[0,4]}" != "http" ]
        then
            url="https://$url"
        fi
        open "$url"
    else
        echo "Unable to get url"
    fi
}
