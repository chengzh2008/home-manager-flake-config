## how to use

## install nix

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
`

## install standalone home-manager

`nix-shell '<home-manager>' -A install`

(which is not necessary as you can do this `nix run home-manager/master -- switch -b backup --impure --flake .#wsl` below)

## clone the repo

`cd ~/.config`
`git clone <project-url> home-manager`

## install doomemacs (optional)

`git clone https://github.com/hlissner/doom-emacs ~/.emacs.d`
`~/.emacs.d/bin/doom install`

## set default shell to be zsh
`echo "$(which zsh)" | sudo tee -a /etc/shells`
`sudo chsh -s $(which zsh)`

## update and run

### run for a specific user on imac

`home-manager switch --impure --flake .#imac`

### run for a specific user on mbp

`home-manager switch --impure --flake .#mbp`

### run for a specific user on linux

`home-manager switch --impure --flake .#linux`

### run for a specific user on wsl

`home-manager switch --impure --flake .#wsl`
