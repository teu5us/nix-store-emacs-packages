{
  outputs = { self, nixpkgs }: {
    nixosModule =
      { config, lib, pkgs, utils, ... }: {
        nixpkgs.overlays = [
          (import ./default.nix)
        ];
      };
  };
}
