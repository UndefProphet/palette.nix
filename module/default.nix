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
          Or a supported file containing the scheme, from which the `palette` is loaded:
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
          "other"
        ];
        default = "light";
        description = "The color theme variant.";
      };

      opacity = lib.mkOption {
        type = types.float;
        default = 1.0;
        description = "An opacity value between 0 and 1 (0 being fully transparent).";
      };

      baseColors = {
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

      colors = lib.mkOption {
        # A named color is a hex string. Named colors may be nested into
        # groups of any depth, so a group is an attribute set of anything.
        type = types.attrsOf (
          types.oneOf [
            types.str
            (types.attrsOf types.anything)
          ]
        );
        description = "The assignment of palette.";

        # Convert to a palette. Colors may be nested into groups.
        apply =
          value:
          palette-lib.buildNamedPalette {
            colors = value;
            opacity = cfg.opacity;
          };
      };

      cursors = lib.mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {

              package = lib.mkOption {
                type = types.package;
                description = "Crusor package.";
              };

              name = lib.mkOption {
                type = types.str;
                description = "Name of the cursor from the package.";
              };

              size = lib.mkOption {
                type = types.number;
                description = "The size of the cursor.";
              };
            };
          }
        );

        default = { };
        description = "Cursor definitions.";
      };

      icons = lib.mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {

              package = lib.mkOption {
                type = types.package;
                description = "Icon package.";
              };

              name = lib.mkOption {
                type = types.str;
                description = "Name of the icon theme.";
                default = "Not provided";
              };

              light = lib.mkOption {
                type = types.str;
                description = "Name of the icon theme for light icons in the icon theme.";
              };

              dark = lib.mkOption {
                type = types.str;
                description = "Name of the icon theme for dark icons in the icon theme.";
              };

            };
          }
        );

        default = { };
        description = "Icon definitions.";
      };

      fonts = lib.mkOption {
        type = types.submodule {
          options = {
            sizes = lib.mkOption {
              type = types.attrsOf types.float;
              default = { };
              description = "Named font sizes.";
            };
          };

          freeformType = types.attrsOf (
            types.submodule {
              options = {
                package = lib.mkOption {
                  type = types.package;
                  description = "Font package.";
                };

                name = lib.mkOption {
                  type = types.str;
                  description = "Font family name.";
                };
              };
            }
          );
        };

        default = { };
        description = "Font definitions.";
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
          "other"
        ]) (lib.mkDefault metaData.variant);
      in
      {
        palette = {
          author = lib.mkDefault metaData.author;
          inherit variant;
          baseColors = {
            inherit (paletteData) hex;
            inherit (paletteData) rgb;
          };
        };
      }
    ))
  ];
}
