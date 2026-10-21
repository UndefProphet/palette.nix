# Colorschemes

A scheme is any set of `base00`…`baseFF` colors. Provide it inline or as a
file.

## Inline

```nix
{
  palette.colorscheme = {
    base00 = "#1e1e2e";
    base01 = "#181825";
    base0D = "#89b4fa";
  };
}
```

## File

```nix
{
  palette.colorscheme = ./catppuccin.yaml;
}
```

Supported extensions: `.yaml`, `.yml`, `.json`, `.toml`. Colors may sit at the
top level or under a `palette` key; metadata is always read from the top
level.

```yaml
name: Catppuccin Mocha
author: catppuccin
variant: dark

palette:
  base00: "#1e1e2e"
  base0D: "#89b4fa"
```

See the [example schemes](../example).

## Metadata

`author` and `variant` are copied into `palette.author` and `palette.variant`
unless you set them yourself. `variant` must be `light`, `dark` or `other`;
anything else falls back to the default (`light`).

## Normalisation

- Only keys starting with `base` are used.
- Names are lowercased, so a scheme's `base0D` is read as `base0d`.
- Values must be `#RRGGBB`. Longer values are truncated to `#RRGGBB` with a
  warning, shorter ones are rejected.
