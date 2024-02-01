tag: { pkgs, config, lib, ... }:
let
  common-packages = with pkgs; [
    sl
    bashInteractive # related to bash config management
    cachix

    # doom-emacs
    coreutils
    fd
    emacs29
    gd
    ripgrep

    # common
    curl
    git
    gzip
    jq
    nixFlakes
    nixfmt # used as doom nix formatter
    nixpkgs-fmt # used for vscode nix formatter
    wget
  ];
  mbp-packages =
    with pkgs; [
      azure-cli
      awscli2
      coursier
      clang-tools_9
      cmake
      ctags
      docbook5
      eksctl
      expat
      gnupg1
      gnuplot
      graphviz
      grpcurl
      glslang
      inetutils
      ispell
      kubectl
      maven
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
      zlib
    ];
  imac-packages = common-packages;
in
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = {
    "imac" = imac-packages;
    "mbp" = mbp-packages ++ common-packages;
  }."${tag}";

  home.file = {
    # manage doom config; installation is still manuall
    doom = {
      enable = true;
      executable = false;
      recursive = true;
      source = ./doom;
      target = "${builtins.getEnv "HOME"}/.doom.d";
    };
  };

  home.activation = {
    doom = lib.hm.dag.entryAfter [ "onFilesChange" ] ''
      PATH="${config.home.path}/bin:$PATH"
      $HOME/.emacs.d/bin/doom sync
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting = {
      enable = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "vi-mode" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile ./zshrc;
  };

  programs.fzf = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
