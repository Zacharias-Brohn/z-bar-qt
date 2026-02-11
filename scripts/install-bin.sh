#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SCRIPT="./zshell.sh"

prepare_binary() {
	sed -ir "s|QML_ROOT=.*|QML_ROOT=${SCRIPT_DIR}/..|" "$SCRIPT"
}

main() {
	prepare_binary

	sudo cp "$SCRIPT" /usr/bin/zshell
}

main "$@"
