#!/bin/bash

DOTS_DIR=$HOME"/.config/dots"


alacritty () {
	mkdir -p ~/.config/alacritty
	cd ~/.config/alacritty
	ln -s $DOTS_DIR/alacritty.yml
}

cargo () {
	mkdir -p ~/.cargo
	cd ~/.cargo
	ln -s $DOTS_DIR/cargo/config.toml
}

starship () {
	mkdir -p ~/.config
	cd ~/.config
	ln -s $DOTS_DIR/starship.toml
}

i3 () {
	mkdir -p ~/.config
	cd ~/.config
	ln -s $DOTS_DIR/i3
}

gitconfig () {
	cd ~
	ln -s $DOTS_DIR/.gitconfig
}

bashrc () {
	cd ~
	ln -s $DOTS_DIR/.bashrc
}

vimrc () {
	cd ~
	ln -s $DOTS_DIR/.vimrc
}

uair () {
	cd ~/.config
	ln -s $DOTS_DIR/uair
}

rofi () {
	cd ~/.config
	ln -s $DOTS_DIR/rofi
}

polybar () {
	cd ~/.config
	ln -s $DOTS_DIR/polybar
}

fish () {
	cd ~/.config
	ln -s $DOTS_DIR/fish
}

install_gentoo_packages () {
	$doas emerge world
}

install_cargo_packages () {
	cargo install $DOTS_DIR/installedPackages/cargo
}
