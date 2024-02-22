{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, flake-utils, ... }:
    let
      intelmac = "x86_64-darwin"; # or aarch64-darwin
      intellinux = "x86_64-linux"; # or aarch64-darwin
      username = builtins.getEnv "USER";
    in {
      homeConfigurations.mbp = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${intelmac};
        modules = [ (import ./home.nix "mbp") ];
      };

      homeConfigurations.imac = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${intelmac};
        modules = [ (import ./home.nix "imac") ];
      };

      homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${intellinux};
        modules = [ (import ./home.nix "linux") ];
      };

      homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${intellinux};
        modules = [ (import ./home-wsl.nix "wsl") ];
      };
    } // flake-utils.lib.eachDefaultSystem (system: {
      defaultPackage.${system} = home-manager.defaultPackage.${system};
    });
}
