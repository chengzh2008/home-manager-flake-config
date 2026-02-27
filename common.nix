pkgs:
with pkgs; [
  sl
  bashInteractive # related to bash config management
  cachix

  # doom-emacs
  csharpier
  coreutils
  fd
  emacs
  ripgrep

  #vscode

  # common
  curl
  git
  git-credential-manager
  gzip
  jq
  #nixFlakes
  nixfmt # used as doom nix formatter
  nixpkgs-fmt # used for vscode nix formatter
  wget
  
  # language:w

  rustup
  go
]
