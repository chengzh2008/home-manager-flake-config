{ lib, ... }:
import ../../modules/shared-home-files.nix {
  inherit lib;
  variantDir = ./.;
}
