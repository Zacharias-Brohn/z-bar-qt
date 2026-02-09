#!/usr/bin/env bash

OS="arch"
if [[ $(ls ./tmp) ]]; then
	exec mkdir ./tmp
fi

cd ./tmp

main() {
	local OPTARG OPTIND opt
	while getopts "arch:nix:" opt; do
		case "$opt" in
		arch) OS=$OPTARG ;;
		nix) OS=$OPTARG ;;
		*) fatal 'bad option' ;;
		esac
	done

	if [[ $OS = "arch" ]]; then
		exec yay -Sy
	elif [[ $OS = "nix" ]]; then
		exec nixos-rebuild build --flake $HOME/Gits/NixOS/#nixos
		PKGS=$(exec nix store diff-closures /run/current-system ./result)
	fi
}

main "$@"
