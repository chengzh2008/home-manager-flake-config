{ pkgs, ... }:
{
  nix.package = pkgs.nix;
  nixpkgs.config.allowUnfree = true;
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";
}
