tag:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  common-packages = import ./common.nix pkgs;
in
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";

  fonts.fontconfig.enable = true;

  home.packages = { "wsl" = common-packages; }.${tag};

  home.file = {
    ".omnisharp/omnisharp.json".text = builtins.toJSON {
      MsBuild = {
        LoadProjectsOnDemand = true;
      };
    };
  };

  # there are issues when managing doom files through home-manager

  programs = import ./programs.nix pkgs;
}
