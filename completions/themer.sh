# shellcheck shell=bash

# based on https://tylerthrailkill.com/2019-01-19/writing-bash-completion-script-with-subcommands/

_themer_install() {
	local cur="${COMP_WORDS[COMP_CWORD]}"

	local -a dirs=()
	for dir in "$BM_SRC/packages"/*; do
		dir="$(basename "$dir")"
		dirs+=("${dir/--//}")
	done

	# shellcheck disable=SC2207
	COMPREPLY=($(IFS=' ' compgen -W "${dirs[*]}" -- "$cur"))
}

_themer() {
	local i=1 cmd

	# iterate over COMP_WORDS (ending at currently completed word)
	# this ensures we get command completion even after passing flags
	while [[ "$i" -lt "$COMP_CWORD" ]]; do
		local s="${COMP_WORDS[i]}"
		case "$s" in
		# if our current word starts with a '-', it is not a subcommand
		-*) ;;
		# we are completing a subcommand, set cmd
		*)
			cmd="$s"
			break
			;;
		esac
		(( i++ ))
	done

	# check if we're completing 'themer'
	if [[ "$i" -eq "$COMP_CWORD" ]]; then
		local cur="${COMP_WORDS[COMP_CWORD]}"
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "--program --theme --tty --help --version" -- "$cur"))
		return
	fi

	# if we're not completing 'themer', then we're completing a subcommand
	case "$cmd" in
	*)
		COMPREPLY=() ;;
	esac

} && complete -F _themer themer
