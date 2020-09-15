# shellcheck disable=SC1090,1091
# ~/.zshrc: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

[ -z "$PS1" ] && return
_done() {
    if [[ $1 -eq 0 ]]; then
        printf "[\033[0;32m done \033[0m]\n"
    else
        printf "[\033[0;31m failed \033[0m]\n"
    fi
}

set -o vi
setopt inc_append_history_time hist_ignore_space prompt_subst
fpath=(~/.zsh "$fpath")

[ "$TERM" != "unknown" ] && printf "Loading env vars ... "

# Update path unless it has already been done
if [ -z "$BASEPATH" ]
then
    export BASEPATH="$PATH"
fi
export PATH="$HOME/bin:$BASEPATH:$HOME/go/bin:$HOME/repos/cloud-makefiles/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

export AWS_PROFILE=default
export AWS_DEFAULT_REGION=us-east-1

# shellcheck disable=SC2155
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=true
export PERIOD=30
# shellcheck disable=SC1087,SC2154
precmd() {
    # From profile.d/git.sh
    # Remember if you bs :w doesn't work
    #           String before git info       String after git info                                                      Git info fmt
     __git_ps1 " %B%F{yellow}%K{17}%5d%k%f%b" " $(_show_workspace)|$(_show_doormat_info)|%F{blue}$AWS_DEFAULT_REGION%f %#> " " %s"
}

export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history

export GOPATH=~/go
export GOPRIVATE=github.com/hashicorp

export CLICOLOR=true
export LSCOLORS='exgxHxDxCxaDedecgcEhEa'
export GREP_COLORS='1;33;44'

export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:/usr/share/man:/usr/local/share/man:/usr/X11/share/man"
export shoveDir=/tmp/shove

[ "$TERM" != "unknown" ] && _done $?

 
[ "$TERM" != "unknown" ] && printf "Dynamic files: \n"
#Source everything in profile.d
INDENT=$(echo -e "  \xe2\x86\xb3")
if [ -d ~/profile.d ]; then
    for i in ~/profile.d/*.sh; do
        if [ -r "$i" ]; then
            # shellcheck disable=SC2086
            [ "$TERM" != "unknown" ] && printf "%s %s ... " "$INDENT" "$(basename $i)"
            if ! shellcheck -s bash "$i" > /dev/null
            then
                [ "$TERM" != "unknown" ] && _done 1
            else
                source "$i"
                [ "$TERM" != "unknown" ] && _done $?
            fi
        fi
    done
fi

tab_random

[ "$TERM" != "unknown" ] && printf "\033[0mSetting aliases ..."
#ALIAS SECTION
#alias grep='ggrep --color=always'
alias bs='edit_profile'
alias retry='edit_profile true'
alias cleanup='clean_profiles'
alias undo='undo_profile_change'
alias lsp='list_profiles'
alias sb='. ~/.zshrc'
alias bp='vi ~/profile.d; . ~/.zshrc'
alias pshs='python -m SimpleHTTPServer 8585'
alias da='deactivate'
alias ll='ls -lah'
alias lg='ls -lah | grep'
#alias lsi='~/tools/lsi.sh'
#alias icat='~/tools/imgcat.sh'
alias gpa='gitpullall'
alias gpd='gitpulldirs'
alias ravenproxy='ssh -CnfND 8080 raven'
alias fh='fixhost'
alias y2j="python3 -c 'import sys, yaml, json; yaml.add_multi_constructor(\"!\", lambda loader, suffix, node: \"{} {}\".format(suffix, node.value)); json.dump(yaml.load(sys.stdin), sys.stdout, indent=4, sort_keys=True, default=str)'"
alias dcp="docker-compose"
alias dm="docker-machine"
alias dmstart='eval $(docker-machine env main)'
alias netstat='lsof -PMni4 | grep LISTEN'
alias realnetstat='/usr/sbin/netstat'
alias ap='aws_profile'
alias ar='aws_region'
alias sv='source_vars'
alias vv='vi ~/.private'
alias glog='git log --pretty=oneline -n'
alias gclean="gitBranchClean"
[ "$TERM" != "unknown" ] && _done $?
#FUNCTIONS FOR FUN AND AWESOMENESS
hist() {
    grep "$*" "$HOME/.zsh_history"
}

source_vars() {
    source "$HOME/.private/$1.env"
}
