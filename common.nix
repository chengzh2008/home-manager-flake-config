pkgs: with pkgs; [
  sl
  bashInteractive # related to bash config management
  cachix

  # doom-emacs
  csharpier
  coreutils
  fd
  emacs
  ripgrep
  # neovim - managed by lazyvim-nix

  #vscode

  # cloud
  azure-cli

  # common
  curl
  #git
  git-credential-manager
  gzip
  jq
  #nixFlakes
  nixfmt # used as doom nix formatter
  nixpkgs-fmt # used for vscode nix formatter
  wget
  fnm # fast node version manager
  statix

  # language:w

  rustup
  go
  python3
]
