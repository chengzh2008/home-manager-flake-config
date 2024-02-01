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
    emacs29
    ripgrep

    curl
    git
    gzip
    jq
    nixFlakes
    nixpkgs-fmt
  ];

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
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile ./imac-zshrc;
  };

  programs.fzf = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
