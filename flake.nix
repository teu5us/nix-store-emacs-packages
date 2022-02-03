{
  outputs = { self, nixpkgs }: {
    module =
      { config, lib, pkgs, utils, ... }: {
        nixpkgs.overlays = [
          (import ./default.nix)
        ];
      };
  };
}
