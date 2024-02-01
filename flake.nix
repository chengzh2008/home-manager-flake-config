{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      arch = "x86_64-darwin"; # or aarch64-darwin
      username = builtins.getEnv "USER";
    in
    {
      defaultPackage.${arch} =
        home-manager.defaultPackage.${arch};

      homeConfigurations.mbp =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${arch};
          modules = [ (import ./home.nix "mbp") ];
        };

      homeConfigurations.imac =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${arch};
          modules = [ (import ./home.nix "imac") ];
        };
    };
}
