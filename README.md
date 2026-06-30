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
`sudo chsh -s $(which zsh)`    # after this run, needs to logout and log back in

## if the above won't work for some reason. Add this line to .bashrc will do the trick
```bash
if [ -t 1 ] && [ -x "$HOME/.nix-profile/bin/zsh" ]; then
    exec "$HOME/.nix-profile/bin/zsh" -l
fi
```

## update and run

### run for a specific user on imac

`home-manager switch --impure --flake .#imac`

### run for a specific user on mbp

`home-manager switch --impure --flake .#mbp`

### run for a specific user on linux

`home-manager switch --impure --flake .#linux`

### run for a specific user on linuxArm

`nix run home-manager/master -- switch --flake .#linuxArm --impure`

### run for a specific user on wsl

`home-manager switch --impure --flake .#wsl`

## tests

### nvim code-link plugin

Unit tests for the Neovim "code link" helper (`nvim/lua/codelink.lua`, which
generates Azure DevOps / GitHub links for the current line). They mock `vim`, so
no Neovim is required:

`nix-shell -p lua --run "lua nvim/tests/codelink_spec.lua"`

The command exits non-zero if any assertion fails.

