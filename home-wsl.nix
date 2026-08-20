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

  home.packages =
    {
      "wsl" = common-packages ++ [
        pkgs.gnome-keyring # secret-service daemon + gnome-keyring-daemon
        pkgs.libsecret # provides the `secret-tool` CLI
        pkgs.gcr # provides gcr-prompter (GUI unlock, optional)
      ];
    }
    .${tag};

  # there are issues when managing doom files through home-manager

  programs = import ./programs.nix pkgs;
}
