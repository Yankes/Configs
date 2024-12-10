unset TMP
unset TEMP

export HISTSIZE=4000
export HISTFILESIZE=40000


set -o vi

PS1="\[\033[1;34m\][\$(date +%H:%M)][\u@\h:\w]\$(__git_ps1)\[\033[0m\]\n$ "
