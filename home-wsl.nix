tag:
{ pkgs, config, lib, ... }:
let
  common-wsl-packages = import ./common-wsl.nix pkgs;
in
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = {
    "wsl" = common-wsl-packages;
  }.${tag};

  # there are issues when managing doom files through home-manager

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting = { enable = true; };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "vi-mode" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile ./zshrc;
  };

  programs.fzf = { enable = true; };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
