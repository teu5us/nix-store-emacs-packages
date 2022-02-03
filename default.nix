self: super:

{
  emacsPackages = super.emacsPackages.overrideScope' (self': super': {
    nix-store-emacs-packages = self'.trivialBuild rec {
      pname = "nix-store-emacs-packages";
      ename = "nix-store-emacs-packages";
      src = ./.;
    };
  });
}
