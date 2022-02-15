{
  outputs = { self, nixpkgs }: rec {
    overlay = import ./default.nix;
    nixosModule =
      { config, lib, pkgs, utils, ... }: {
        nixpkgs.overlays = [
          overlay
        ];
      };
  };
}
