#!/usr/bin/env zsh
set -euo pipefail

: "${EVENTS_DIR:=$HOME/events}"
: "${EDITOR:=nvim}"
mkdir -p "$EVENTS_DIR"

cl_list() {
	local events=("$EVENTS_DIR"/*.md(N:t:r))
	(( ${#events} )) && print -l $events || echo "events not found"
}

cl_open() {
	local event desc clean_date clean_desc file

	read -r "event?what's the date of your event (mm/dd/yyyy)? "
	read -r "desc?describe your event: "

	if [[ -z "$event" || -z "$desc" ]]; then
		echo "date and description cannot be empty" >&2
		return 1
	fi

	clean_date="${event//\//-}"
	clean_desc="${desc//\//-}"
	file="$EVENTS_DIR/${clean_date} - ${clean_desc}.md"

	"$EDITOR" "$file"
}

cl_search() {
	if [[ -z "${1:-}" ]]; then
		echo "usage: cl search <query>" >&2
		return 1
	fi
	if ! command -v rg >/dev/null 2>&1; then
		echo "ripgrep required" >&2
		return 1
	fi
	rg -S -- "$1" "$EVENTS_DIR"
}

cl_help() {
	cat <<EOF
cl - minimal calendar

commands:
 	cl list              list events
	cl open              create or edit an event
	cl search <query>    search inside events
	cl help              show this message
EOF
}

case "${1:-}" in
	list) cl_list ;;
	open) cl_open ;;
	search) shift; cl_search "$@" ;;
	help|"") cl_help ;;
	*) echo "unknown command: $1"; cl_help ;;
esac
