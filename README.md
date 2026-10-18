<img src="./assets/banner.png" alt="palette.nix banner" width="100%">

# palette.nix

A small NixOS module that turns a [Base16](https://github.com/tinted-theming/home)
(or any `base00`…`baseFF`) colorscheme into an easily consumable palette for your
Nix configuration.

Load a colorscheme from an attribute set or straight from a YAML / JSON / TOML
file, and get every color back in both **hex** and **RGB** form, each with a
plain, with-opacity, and per-channel representation.

## Features

- Load a colorscheme from an inline attribute set or a file (`.yaml`, `.yml`,
  `.json`, `.toml`).
- Reads `author` and `variant` metadata from the scheme automatically.
- Produces both `hex` and `rgb` renderings of every color.
- Every color exposes `normal`, `withOpacity`, `opacity`, `r`, `g`, and `b`.
- Global `opacity` for generating translucent variants.

## Installation

Add the flake as an input:

```nix
{
  inputs = {
    ...
    palette-nix.url = "github:undefprophet/palette.nix";
  };
}
```

Then import the module into your NixOS configuration:

```nix
{
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

Or, from inside an existing module:

```nix
{
  imports = [ palette-nix.nixosModules.default ];
}
```

## Usage

Enable the module and point it at a colorscheme:

```nix
{
  palette = {
    enable = true;
    # Either a path to a scheme file...
    colorscheme = ./catppuccin.yaml;
    # ...or an inline attribute set:
    colorscheme = {
      base00 = "#1e1e2e";
      base01 = "#181825";
      base02 = "#313244";
      base<n> = "#000000";
      base0F = "#444444";
      base10 = "#444444";
      base11 = "#444444";
      base12 = "#444444";
      ...
    };
  };
}
```

Then read colors from anywhere in your config:

```nix
{ config, ... }:
{
  # Plain hex color
  some.option = config.palette.hex.base00.normal;

  # CSS-style RGB / RGBA strings
  other.option = config.palette.rgb.base0D.normal;      # "rgb(137, 180, 250)"
  translucent.option = config.palette.rgb.base0D.withOpacity;

  # Individual channels
  channels.r = config.palette.hex.base0D.r;             # "89"
  channels.rgb = config.palette.rgb.base0D.r;            # 137

  # Metadata (from the scheme, unless overridden)
  theme.author = config.palette.author;
  theme.mode = config.palette.variant;
}
```

### Setting a global opacity

`opacity` (a float between `0.0` and `1.0`) controls the `withOpacity` values:

```nix
{
  palette.opacity = 0.85;
  # config.palette.hex.base00.withOpacity -> "#1e1e2ed9"
  # config.palette.rgb.base00.withOpacity -> "rgba(30, 30, 46, 0.85)"
}
```

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `palette.enable` | `bool` | `false` | Enable the module. |
| `palette.colorscheme` | `attrsOf str` or `path` | `{}` | Scheme as an attribute set, or a path to a `.yaml`, `.yml`, `.json`, or `.toml` file. |
| `palette.author` | `nullOr str` | `null` | Scheme author. Filled from the scheme metadata when present; can be overridden. |
| `palette.variant` | `"light"` or `"dark"` | `"light"` | Scheme variant. Filled from the scheme metadata when present; can be overridden. |
| `palette.opacity` | `float` | `1.0` | Opacity used for the `withOpacity` values. |
| `palette.hex` | `attrs` (read-only) | — | Computed palette in hex. |
| `palette.rgb` | `attrs` (read-only) | — | Computed palette in RGB. |

## Colorscheme files

A scheme file may keep the colors at the top level or nested under a `palette`
key. Metadata (`author`, `variant`, `name`) is read from the top level.

```yaml
# colorschemes/catppuccin.yaml
name: Catppuccin Mocha
author: catppuccin
variant: dark

palette:
  base00: "#1e1e2e"
  base01: "#181825"
  base02: "#313244"
  base05: "#cdd6f4"
  base0D: "#89b4fa"
```

`variant` is optional. When omitted, `palette.variant` falls back to its default
(`"light"`). Values longer than 7 characters are truncated to `#RRGGBB` with a
warning; shorter values are rejected.

## Output shape

For each color you get a set like the following:

```nix
config.palette.hex.base00
# {
#   normal      = "#1e1e2e";
#   withOpacity = "#1e1e2eff";
#   opacity     = "ff";
#   r = "1e";
#   g = "1e";
#   b = "2e";
# }

config.palette.rgb.base00
# {
#   normal      = "rgb(30, 30, 46)";
#   withOpacity = "rgba(30, 30, 46, 1.000000)";
#   opacity     = "1.000000";
#   r = 30;
#   g = 30;
#   b = 46;
# }
```

The top-level `config.palette` also exposes `author` and `variant`.

## License

See the repository for license information.
