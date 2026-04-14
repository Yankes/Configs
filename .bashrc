unset TMP
unset TEMP

export HISTSIZE=4000
export HISTFILESIZE=40000


set -o vi

PS1="\[\033[1;34m\][\$(date +%H:%M)][\u@\h:\w]\$(__git_ps1)\[\033[0m\]\n$ "



function detached_git()
{
	local workTree=$1
	local gitRepo=$2
	local op=$3
	local restArgs=("${@:4}")
	local gitDetachArgs=(-C "$workTree" --work-tree="$workTree" --git-dir="$gitRepo"/.git);
	case $op in
		clone)
			if [[ -d "$gitRepo" ]]; then
				echo "Already created";
				return 1;
			else
				git clone "${restArgs[0]}" "$gitRepo" &&
				if ! grep -q '^*$' "$gitRepo"/.git/info/exclude; then
					echo '*' >> "$gitRepo"/.git/info/exclude;
				fi;
			fi;
		;;

		init)
			if [[ -d "$gitRepo" ]]; then
				echo "Already created";
				return 1;
			else
				mkdir "$gitRepo" && (cd "$gitRepo" && git init) &&
				if ! grep -q '^*$' "$gitRepo"/.git/info/exclude; then
					echo '*' >> "$gitRepo"/.git/info/exclude;
				fi;
			fi;
		;;

		diff)
			git "${gitDetachArgs[@]}" diff -- "${restArgs[@]}"
		;;

		add)
			git "${gitDetachArgs[@]}" add -f -- "${restArgs[@]}"
		;;

		checkin)
			git "${gitDetachArgs[@]}" add -p -- "${restArgs[@]}"
		;;

		checkout)
			git "${gitDetachArgs[@]}" checkout -p HEAD~0 -- "${restArgs[@]}"
		;;

		commit)
			(cd "$gitRepo"; git commit "${restArgs[@]}")
		;;

		push)
			(cd "$gitRepo"; git push "${restArgs[@]}")
		;;

		pull)
			(cd "$gitRepo"; git pull "${restArgs[@]}")
		;;

		raw-work-tree)
			git "${gitDetachArgs[@]}" "${restArgs[@]}"
		;;

		raw-git-repo)
			(cd "$gitRepo"; git "${restArgs[@]}")
		;;

		*)
			echo "Unknown option";
			return 1;
		;;
	esac;
}

function config_git()
{
	detached_git "$HOME" "$HOME/Configs" "$@"
}

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
		sleep 1
		tmux send-keys -l '' "${tt/% /};" send-keys ENTER;
	else
		echo "no command given";
	fi;
}


complete -F _proxy_command_complete rt1
complete -F _proxy_command_complete rt2
complete -F _proxy_command_complete rt3
