tag:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  common-packages = import ./common.nix pkgs;
  mbp-packages = import ./mbp.nix pkgs;
  imac-packages = import ./imac.nix pkgs;
  linux-packages = import ./linux.nix pkgs;
in
{
  nix.package = pkgs.nix;
  nixpkgs.config.allowUnfree = true;
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";

  home.packages =
    {
      "imac" = imac-packages ++ common-packages;
      "linux" = linux-packages ++ common-packages;
      "linuxArm" = linux-packages ++ common-packages;
      ## "wsl" = common-packages;
      "mbp" = mbp-packages ++ common-packages;
    }
    .${tag};

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

  # Create custom plugins file
  home.file.".config/nvim/lua/plugins/mdeval.lua".text = ''
    return {
      {
        'jubnzv/mdeval.nvim',
        config = true,
        ft = { 'markdown' },
      }
    }
  '';

  # Azure DevOps / GitHub: copy/open a code link for the current line or visual selection.
  home.file.".config/nvim/lua/codelink.lua".source = ./nvim/lua/codelink.lua;
  home.file.".config/nvim/lua/plugins/azdo-link.lua".source = ./nvim/azdo-link.lua;

  # home.activation = {
  #   doom = lib.hm.dag.entryAfter [ "onFilesChange" ] ''
  #     PATH="${config.home.path}/bin:$PATH"
  #     $HOME/.emacs.d/bin/doom sync
  #   '';
  # };

  programs = import ./programs.nix pkgs;
}
