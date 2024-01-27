{ pkgs, config, lib, ... }:
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    sl
    bashInteractive # related to bash config management
    cachix

    # doom-emacs dependencies
    coreutils
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
    shfmt
    shellcheck
    ripgrep

    curl
    git
    jq
    nixFlakes
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting = {
      enable = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    #initExtra = builtins.readFile ./zshrc;
    initExtra = ''
      bindkey '^f' autosuggest-accept
      export TERM=xterm-256color
      #shell prompt
      case $TERM
        in xterm*)
          precmd () {print -Pn "\e]0;&n@%m: %~\a"}
          ;;
      esac
      # path
      export PATH=$HOME/.emacs.d/bin:$PATH
    '';
  };

  programs.fzf = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
