unset TMP
unset TEMP

export HISTSIZE=4000
export HISTFILESIZE=40000


set -o vi

PS1="\[\033[1;34m\][\$(date +%H:%M)][\u@\h:\w]\$(__git_ps1)\[\033[0m\]\n$ "



_proxy_command_complete() {
	local first second old_line;
	first=$COMP_WORDS;
	second=${COMP_WORDS[1]};
	old_line=$COMP_LINE;
	
	if [[ -z "$second" ]]; then return; fi;
	if [[ $COMP_CWORD -le 1 ]]; then COMPREPLY=( $(compgen -A command -- "$second") ); return; fi;
	
	COMP_WORDS=("${COMP_WORDS[@]:1}");
	COMP_LINE=${COMP_LINE##"$first"*( )};
	COMP_CWORD=$(($COMP_CWORD - 1));
	COMP_POINT=$(($COMP_POINT - ( ${#old_line} - ${#COMP_LINE} ) ));
	
	if complete -p "$second" 1>/dev/null 2>&1; then
		$(complete -p "$second" 2>/dev/null | sed -nE 's/.+-F ([^ ]+) .+/\1/p') "${second}" "${@:2}";
	else
		COMPREPLY=('##Error##' '!!NO COMMAND MATCHED!!');
	fi;
}


rt1() {
	if [[ $# -gt 0 ]]; then
		(tput smcup; trap 'tput rmcup' SIGTERM EXIT; "$@");
	else
		echo "no command given";
	fi;
}


rt2() {
	if [[ $# -gt 0 ]]; then
		false ||
			tmux respawnp -k -t .2 "$(printf "%q " "${@}") && read || (echo 'Error, closing...'; sleep 5s)" 2>/dev/null ||
			tmux split-pane -h -d "$(printf "%q " "${@}") && read || (echo 'Error, closing...'; sleep 5s)";
	else
		echo "no command given";
	fi;
}


rt3() {
        if [[ $# -gt 0 ]]; then
                local tt;
                tt="$(printf "%q " "${@}")";
                tmux new-window
                tmux send-keys -l '' "${tt/% /};" send-keys ENTER;
        else
                echo "no command given";
        fi;
}


complete -F _proxy_command_complete rt1
complete -F _proxy_command_complete rt2
complete -F _proxy_command_complete rt3
