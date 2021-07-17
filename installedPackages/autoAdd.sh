#!/bin/bash
# auto add script when login fish-shell

# cargo
# local(go pip)
# emerge

ls ~/.cargo/bin > ~/.config/dots/installedPackages/cargo
ls ~/.local/bin > ~/.config/dots/installedPackages/local
cat /var/lib/portage/world > world
