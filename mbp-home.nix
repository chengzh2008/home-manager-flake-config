{ pkgs, config, lib, ... }:
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    sl
    azure-cli
    awscli2
    bashInteractive # related to bash config management
    cachix
    coursier
    clang-tools_9
    cmake
    coreutils
    curl
    ctags
    docbook5
    eksctl
    expat
    emacs29
    fd
    gd
    git
    gnupg1
    gnuplot
    graphviz
    grpcurl
    glslang
    inetutils
    ispell
    jq
    kind
    kubectl
    kubernetes-helm-wrapped
    kustomize
    maven
    nixFlakes
    nixpkgs-fmt
    pandoc
    pass
    pipx
    #prometheus
    #rust-analyzer
    ruff
    shfmt
    shellcheck
    ripgrep
    sourceHighlight
    texinfo
    tmux
    tree
    tree-sitter
    utf8proc
    wget
    zsh
    zlib
  ];

  programs.fzf = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
