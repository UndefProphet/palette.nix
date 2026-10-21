# Options

All options live under `palette`.

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `palette.enable` | `bool` | `false` | Load the colorscheme. |
| `palette.colorscheme` | `attrsOf str` or `path` | `{}` | Scheme as an attribute set, or a path to a `.yaml`, `.yml`, `.json` or `.toml` file. See [Colorschemes](./colorscheme.md). |
| `palette.colors` | `attrs` | `{}` | Named colors, optionally nested into groups. See [Named colors](./colors.md). |
| `palette.author` | `nullOr str` | `null` | Scheme author. Taken from the scheme metadata, overridable. |
| `palette.variant` | `"light"`, `"dark"` or `"other"` | `"light"` | Scheme variant. Taken from the scheme metadata, overridable. |
| `palette.opacity` | `float` | `1.0` | Opacity used for the `withOpacity` values. |
| `palette._startIncrementFromOneGetBase` | `bool` | `false` | Count `getBase <int>` from 1 instead of 0. |
| `palette.baseColors.hex` | `attrs` (read-only) | - | Scheme colors in hex. |
| `palette.baseColors.rgb` | `attrs` (read-only) | - | Scheme colors in RGB. |
| `palette.fonts` | `attrs` | `{}` | Fonts and font sizes. See [Assets](./assets.md). |
| `palette.cursors` | `attrs` | `{}` | Cursors. See [Assets](./assets.md). |
| `palette.icons` | `attrs` | `{}` | Icon themes. See [Assets](./assets.md). |

## Output shape

Every color, from the scheme or from `palette.colors`, exists in both
formats and carries the same attributes:

| Attribute | `hex` | `rgb` |
| --- | --- | --- |
| `normal` | `"#1e1e2e"` | `"rgb(30, 30, 46)"` |
| `withoutHash` | `"1e1e2e"` | - |
| `withOpacity` | `"#1e1e2ed9"` | `"rgba(30, 30, 46, 0.850000)"` |
| `opacity` | `"d9"` | `"0.850000"` |
| `r`, `g`, `b` | `"1e"`, `"1e"`, `"2e"` | `30`, `30`, `46` |

The values above assume `palette.opacity = 0.85`. The alpha channel is the
opacity rounded to a byte, so it is `"ff"` at the default opacity of `1.0`.

Paths:

```nix
{ config, ... }:
{
  # the scheme colors
  scheme = with config.palette.baseColors; {
    base00 = hex.base00.normal;
    base0d = rgb.base0d.normal;
  };

  # your named colors
  named = with config.palette.colors; {
    text = hex.text.normal;
    editor = rgb.programming.editor.background.normal;
  };
}
```

`config.palette` additionally exposes `author` and `variant`.
