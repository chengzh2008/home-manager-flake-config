{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fd
    nerd-fonts.symbols-only
    nixfmt
    nixpkgs-fmt
    ripgrep
    statix
    tmux
    python3
    fnm

    /*
      installed outside of nix
      git
      git-credential-manager
      azure-cli
      curl
      gh
      gzip
      jq
      wget
      python3
    */
  ];
}
