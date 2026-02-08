pkgs:
with pkgs; [
  sl
  bashInteractive # related to bash config management
  cachix

  # doom-emacs
  csharpier
  coreutils
  fd
  emacs29
  ripgrep

  #vscode
  vscode

  # common
  curl
  git
  gzip
  jq
  nixFlakes
  nixfmt # used as doom nix formatter
  nixpkgs-fmt # used for vscode nix formatter
  wget
]
