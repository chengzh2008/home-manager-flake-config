tag:
{ pkgs, config, lib, ... }:
let
  common-packages = import ./common.nix pkgs;
  mbp-packages = import ./mbp.nix pkgs;
in {
  nix.package = pkgs.nix;
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";

  home.packages = {
    "imac" = common-packages;
    "linux" = common-packages;
    "wsl" = common-packages;
    "mbp" = mbp-packages ++ common-packages;
  }.${tag};

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

  programs = import ./programs.nix;
}
