## how to use

## install nix

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
`

## install standalone home-manager

`nix-shell '<home-manager>' -A install`

## clone the repo

`cd ~/.config`
`git clone <project-url> home-manager`

## update and run

### run for a specific user on imac

`home-manager switch --impure --flake .#imac`

### run for a specific user on mbp

`home-manager switch --impure --flake .#mbp`
