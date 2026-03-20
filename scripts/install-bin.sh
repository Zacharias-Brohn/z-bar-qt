#!/usr/bin/env bash

BINARY="../Greeter/scripts/start-zshell-greeter"
CONFIG="../Greeter/scripts/zshell-hyprland.conf"
GREETD_CONFIG="../Greeter/scripts/greeter-config.toml"
WALLPAPER="$HOME/.local/state/zshell/lockscreen_bg.png"
FACE="$HOME/.face"

main() {
	sudo mkdir -p "/etc/zshell-greeter/images"
	sudo cp "$BINARY" "/usr/bin"
	sudo cp "$CONFIG" "/etc/zshell-greeter"
	sudo cp "$WALLPAPER" "/etc/zshell-greeter/images/greeter_bg.png"
	sudo cp "$FACE" "/etc/zshell-greeter/images/face"
	sudo cp "$GREETD_CONFIG" "/etc/greetd/config.toml"
}

main "$@"
