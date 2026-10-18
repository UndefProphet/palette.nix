{
  config,
  lib,
  pkgs,
  ...
}:
let
  palette-lib = import ./lib.nix { inherit lib pkgs; };
in
{
  options.palette =
    let
      inherit (lib) types;
    in
    {
      enable = lib.mkEnableOption "";

      colorscheme = lib.mkOption {
        type = types.either (types.attrsOf types.str) (types.path);
        default = { };
        description = ''
          Base16 (or any other base up to 255) colorscheme colors (attrs) or path to a colorscheme file
          Example:
            colorscheme = {
              base00 = "#222222";
              base01 = "#222222";
              ...
              base0E = "#222222";
              base0F = "#222222";
            };
          Or a YAML file containing the scheme, from which the `palette` is loaded:
            colorscheme = ./colorscheme.yaml
        '';
      };

      author = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The author of colorscheme.";
      };

      variant = lib.mkOption {
        type = types.enum [
          "light"
          "dark"
        ];
        default = "light";
        description = "The color theme variant.";
      };

      opacity = lib.mkOption {
        type = types.float;
        default = 1.0;
        description = "An opacity value between 0 and 1 (0 being fully transparent).";
      };

      hex = lib.mkOption {
        type = types.attrsOf types.anything;
        readOnly = true;
        description = "Color palette in hex format.";
      };

      rgb = lib.mkOption {
        type = types.attrsOf types.anything;
        readOnly = true;
        description = "Color palette in RGB format.";
      };
    };

  config =
    let
      cfg = config.palette;
    in
    (lib.mkIf cfg.enable (
      let
        paletteData = palette-lib.buildPalette {
          colors = cfg.colorscheme;
          opacity = cfg.opacity;
        };
      in
      {
        palette = {
          hex = paletteData.hex;
          rgb = paletteData.rgb;
          author = lib.mkDefault paletteData.author;
          variant = lib.mkIf (builtins.elem paletteData.variant [
            "dark"
            "light"
          ]) (lib.mkDefault paletteData.variant);
        };
      }
    ));
}
