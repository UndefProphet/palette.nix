# Color mixing

`config.lib.palette` ships pure color-mixing helpers. They take hex strings in
`#RRGGBB` form and return a new `#RRGGBB` string; channels are combined as
floats and truncated to integers, so a result is never rounded up.

```nix
{ config, ... }:
with config.lib.palette;
with config.palette.baseColors.hex;
{
  some.option = tint 0.5 base00.normal;
}
```

| Function | Signature | Description |
| --- | --- | --- |
| `linearMixRatio` | `ratioB → colorA → colorB → hex` | Linear interpolation. `0` returns `colorA`, `1` returns `colorB`. |
| `evenMix` | `colorA → colorB → hex` | Even 50/50 mix, shorthand for `linearMixRatio 0.5`. |
| `tint` | `ratio → color → hex` | Mix a color towards white (`1` is white). |
| `shade` | `ratio → color → hex` | Mix a color towards black (`1` is black). |
| `multiplyMix` | `colorA → colorB → hex` | Multiplicative (subtractive) blend. |
| `screenMix` | `colorA → colorB → hex` | Screen (additive) blend. |
| `dodge` | `colorA → colorB → hex` | Color dodge; lightens `colorA` by `colorB`. |
| `burn` | `colorA → colorB → hex` | Color burn; darkens `colorA` by `colorB`. |

## Examples

```nix
{ config, ... }:
with config.lib.palette;
{
  mixed = linearMixRatio 0.25 "#ff0000" "#0000ff";  # "#bf003f"
  even = evenMix "#ff0000" "#0000ff";              # "#7f007f"
  lighter = tint 0.5 "#808080";                    # "#bfbfbf"
  darker = shade 0.5 "#808080";                    # "#404040"
  multiplied = multiplyMix "#ff8000" "#8080ff";    # "#804000"
  screened = screenMix "#ff8000" "#8080ff";        # "#ffc0ff"
  dodged = dodge "#808080" "#404040";              # "#aaaaaa"
  burned = burn "#808080" "#c0c0c0";               # "#575757"
}
```

`dodge` and `burn` are clamped to `#000000`…`#ffffff`, and their degenerate
cases are guarded: dodging with a white blend yields white, burning with a
black blend yields black.

## Chaining

`tint` and `shade` take the color as their last argument, so Nix's `|>` pipes
straight into a partially applied call:

```nix
{ config, ... }:
with config.lib.palette;
with config.palette.baseColors.hex;
base00.normal
|> tint 0.2
|> shade 0.1
```

The blends take the color first, so wrap them in a lambda:

```nix
{ config, ... }:
with config.lib.palette;
with config.palette.baseColors.hex;
base00.normal
|> (c: multiplyMix c "#88aaff")
|> (c: dodge c "#202020")
```

### Without the pipe operator

`|>` needs Nix 2.24 or newer. On versions where it is still experimental,
enable it with `experimental-features = [ "pipes" ]`. If you cannot use it,
`lib.pipe` from nixpkgs applies the same steps from left to right:

```nix
{ config, lib, ... }:
with config.lib.palette;
with config.palette.baseColors.hex;
lib.pipe base00.normal [
  (tint 0.2)
  (shade 0.1)
  (c: multiplyMix c "#88aaff")
]
```

Nix does not parse function application inside a list, so every step needs its
own parentheses.
