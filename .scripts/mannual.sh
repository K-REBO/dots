#!/bin/bash
doas="doas" # or `sudo`



starfetch () {
	git clone https://github.com/Haruno19/starfetch
	cd starfetch
	make -j8
	$doas make install
}



starfetch
