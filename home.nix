tag: { pkgs, config, lib, ... }:
let
  mbp-packages =
    with pkgs; [
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
      gzip
      inetutils
      ispell
      jq
      kubectl
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
      zlib
    ];
  imac-packages = with pkgs; [
    sl
    bashInteractive # related to bash config management
    cachix

    # doom-emacs dependencies
    coreutils
    fd
    emacs29
    ripgrep

    curl
    git
    gzip
    jq
    nixFlakes
    nixpkgs-fmt
  ];
in
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = {
    "imac" = imac-packages;
    "mbp" = mbp-packages;
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
