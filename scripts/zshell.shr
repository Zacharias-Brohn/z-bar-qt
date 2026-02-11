#!/usr/bin/env bash

QML_ROOT=/home/zach/GitProjects/z-bar-qt/scripts/..
LOCK=false

main() {
	local OPTARG OPTIND opt
	while getopts "l" opt; do
		case "$opt" in
		l) LOCK=true ;;
		*) fatal 'bad option' ;;
		esac
	done

	if [[ "$LOCK" = "true" ]]; then
		hyprctl dispatch global zshell-lock:lock
	else
		qs -n -d -p "$QML_ROOT/shell.qml"
	fi
}

main "$@"
