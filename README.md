<img src="./assets/banner.png" alt="palette.nix banner" width="100%">

# palette.nix

A small NixOS module that turns a [Base16](https://github.com/tinted-theming/home)
(or any `base00`…`baseFF` / 0 to 255) colorscheme into a ready-to-use palette.

Load a scheme from an attribute set or a YAML / JSON / TOML file and get every
color back in **hex** and **RGB**: plain, translucent and per channel.

It also gives you:

- **Named colors** of your own (`text`, `border`, …), grouped as deep as you like
- **Color mixing** helpers: `tint`, `shade`, `multiplyMix`, `dodge`, `burn`, …
- **Assets**: fonts, cursors and icon themes, kept next to the scheme with respective sizes

## Documentation

| | |
| --- | --- |
| [Options and output shape](./docs/options.md) | Every option and the shape of a color. |
| [Colorschemes](./docs/colorscheme.md) | Where schemes come from and how they are normalised. |
| [Named colors](./docs/colors.md) | Meaning-based colors, groups and `getBase`. |
| [Color mixing](./docs/color-mixing.md) | `tint`, `shade`, blend modes and chaining. |
| [Assets](./docs/assets.md) | Fonts, cursors and icon themes. |
| [Example](./example) | A complete configuration. |

## Install

```nix
{
  inputs.palette-nix.url = "github:undefprophet/palette.nix";

  outputs = { nixpkgs, palette-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        palette-nix.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
```

## Example

```nix
{ config, pkgs, ... }:
{
  palette = {
    # Load the scheme
    enable = true;

    # A scheme file (.yaml, .yml, .json, .toml) or an attribute set of
    # `baseNN` colors
    colorscheme = ./catppuccin.yaml;

    # Opacity used for the `withOpacity` values
    opacity = 0.9;

    # Your own names for the colors, grouped as deep as you like
    colors = {
      text = "#cdd6f4";
      background = "#1e1e2e";
      programming = {
        editor = { background = "#1e1e2e"; };
      };
    };

    # Fonts, any number of them, plus named sizes
    fonts = {
      sizes = {
        terminal = 9.0;
        desktop = 10.0;
        popups = 11.0;
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMonoNL Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
    };

    # Icon themes, each with a light and a dark name
    icons = {
      main = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus Icon Theme";
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };
      monochrome = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        dark = "Adwaita";
        light = "Adwaita";
      };
    };

    # Cursors work the same way
    cursors = {
      main = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
      large = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 32;
      };
    };
  };

  # Read the colors back in any option of your own
  environment.sessionVariables =
    with config.palette.baseColors.hex;
    with config.palette.colors.hex;
    with config.lib.palette;
    {
      # Scheme colors, in hex or rgb
      BACKGROUND = base00.normal;
      FOREGROUND = base0d.normal;

      # Your named colors, grouped as you declared them
      TEXT = text.normal;
      EDITOR = programming.editor.background.normal;

      # Mix colors, straight from the scheme
      HIGHLIGHT = tint 0.5 config.palette.baseColors.hex.base00.normal;
    };
}
```

## License

See the repository for license information.

## Disclaimer!

The readme files were largely written using large language models.
