{
  description = "A NixOS module that loads colorschemes and exposes their colors as different formats including with opacity";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: f nixpkgs.legacyPackages.${system});
    in
    {

      nixosModules.default = ./module;
      # homeManagerModule.default = { } ;
      # hjemModule = { };

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
