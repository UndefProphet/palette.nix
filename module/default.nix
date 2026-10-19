{
  config,
  lib,
  pkgs,
  ...
}:
let
  palette-lib = import ./lib.nix { inherit lib pkgs; };
  color-mixing = import ./color-mixing.nix { inherit lib; };
  user-lib = import ./user-lib.nix { inherit lib config; };
  cfg = config.palette;
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

      base = {
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

      named = lib.mkOption {
        type = types.attrsOf types.str;
        description = "The assignment of palette.";

        # Convert to a palette
        apply =
          value:
          palette-lib.buildPalette {
            colors = value;
            opacity = cfg.opacity;
            skipBaseCheck = true;
          };
      };
    };

  config = lib.mkMerge [
    {
      lib.palette = {
        inherit (color-mixing)
          linearMixRatio
          evenMix
          tint
          shade
          multiplyMix
          screenMix
          dodge
          burn
          ;
        inherit (user-lib)
          getBase
          ;
      };
    }
    (lib.mkIf cfg.enable (
      let
        metaData = palette-lib.buildMeta cfg.colorscheme;
        paletteData = palette-lib.buildPalette {
          colors = cfg.colorscheme;
          opacity = cfg.opacity;
        };
        variant = lib.mkIf (builtins.elem metaData.variant [
          "dark"
          "light"
        ]) (lib.mkDefault metaData.variant);
      in
      {
        palette = {
          author = lib.mkDefault metaData.author;
          inherit variant;
          base = {
          inherit (paletteData) hex;
          inherit (paletteData) rgb;
          };
        };
      }
    ))
  ];
}
