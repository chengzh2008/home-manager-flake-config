{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-utils,
      lazyvim,
      ...
    }:
    let
      variants = {
        mbp = {
          system = "x86_64-darwin";
          directory = ./variants/mbp;
        };
        imac = {
          system = "x86_64-darwin";
          directory = ./variants/imac;
        };
        linux = {
          system = "x86_64-linux";
          directory = ./variants/linux;
        };
        linuxArm = {
          system = "aarch64-linux";
          directory = ./variants/linux;
        };
        wsl = {
          system = "x86_64-linux";
          directory = ./variants/wsl;
        };
      };

      mkHomeConfiguration =
        _:
        {
          system,
          directory,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            lazyvim.homeManagerModules.default
            ./home.nix
            (directory + "/default.nix")
          ];
        };
    in
    {
      homeConfigurations = builtins.mapAttrs mkHomeConfiguration variants;
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      defaultPackage.${system} = home-manager.defaultPackage.${system};
    });
}
