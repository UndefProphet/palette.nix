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
          The colorscheme to load: either an attribute set of base00-baseFF
          hex colors (Base16 or any other base up to 255), or a path to a
          .yaml, .yml, .json or .toml colorscheme file.

          Example attribute set:

            colorscheme = {
              base00 = "#222222";
              base01 = "#222222";
              ...
              base0E = "#222222";
              base0F = "#222222";
            };

          Example file:

            colorscheme = ./colorscheme.yaml;
        '';
      };

      author = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Author of the colorscheme. Taken from the colorscheme's metadata
          when available; set here to override.
        '';
      };

      variant = lib.mkOption {
        type = types.enum [
          "light"
          "dark"
          "other"
        ];
        default = "light";
        description = ''
          Variant of the colorscheme. Taken from the colorscheme's metadata
          when available (falling back to "light"); set here to override.
        '';
      };

      opacity = lib.mkOption {
        type = types.float;
        default = 1.0;
        description = ''
          Opacity used for the withOpacity and opacity attributes of every
          color, between 0 (fully transparent) and 1 (fully opaque).
        '';
      };

      _startIncrementFromOneGetBase = lib.mkEnableOption {
        default = false;
        description = ''
          Make getBase <int> count scheme colors from 1 instead of 0, so
          that getBase 1 yields base00. String lookups (getBase "00")
          are unaffected.
        '';
      };

      baseColors = {
        hex = lib.mkOption {
          type = types.attrsOf types.anything;
          readOnly = true;
          description = ''
            Read-only view of the colorscheme colors in hex format, with
            normal, withoutHash, withOpacity, opacity, r, g and
            b attributes on each color.
          '';
        };

        rgb = lib.mkOption {
          type = types.attrsOf types.anything;
          readOnly = true;
          description = ''
            Read-only view of the colorscheme colors in RGB format, with
            normal, withOpacity, opacity, r, g and b attributes
            on each color.
          '';
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
        description = ''
          Named colors declared by meaning, with hex string values
          (#RRGGBB) or nested groups of any depth. Available read-only as
          config.palette.colors in both hex and RGB trees, alongside the
          scheme colors under config.palette.baseColors.
        '';

        # Convert to a palette. Colors may be nested into groups.
        apply =
          value:
          palette-lib.buildNamedPalette {
            nestedColors = value;
            opacity = cfg.opacity;
          };
      };

      cursors = lib.mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {

              package = lib.mkOption {
                type = types.package;
                description = "Package providing the cursor theme.";
              };

              name = lib.mkOption {
                type = types.str;
                description = "Cursor theme name within the package.";
              };

              size = lib.mkOption {
                type = types.number;
                description = "Cursor size.";
              };
            };
          }
        );

        default = { };
        description = ''
          Cursor definitions, stored under the given names and readable back
          via config.palette.cursors.<name>.
        '';
      };

      icons = lib.mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {

              package = lib.mkOption {
                type = types.package;
                description = "Package providing the icon theme.";
              };

              name = lib.mkOption {
                type = types.str;
                description = "Icon theme name within the package.";
                default = "Not provided";
              };

              light = lib.mkOption {
                type = types.str;
                description = "Icon theme name to use for light icons.";
              };

              dark = lib.mkOption {
                type = types.str;
                description = "Icon theme name to use for dark icons.";
              };

            };
          }
        );

        default = { };
        description = ''
          Icon theme definitions, stored under the given names and readable
          back via config.palette.icons.<name>.
        '';
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
                  description = "Package providing the font.";
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
        description = ''
          Font definitions: named fonts (each with a package and a font
          family name) plus a sizes attribute set of named font sizes.
          Readable back via config.palette.fonts.<name> and
          config.palette.fonts.sizes.<name>.
        '';
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
