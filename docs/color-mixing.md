# Color mixing

`config.lib.palette` ships pure color-mixing helpers. They accept any color
format: a hex string in `#RRGGBB` or `RRGGBB` form (the leading `#` is
optional), a hex attrset (`_type = "hex"`) or a rgb attrset
(`_type = "rgb"`). They return a new color value: a rgb attrset
(`_type = "rgb"`, with 0-255 integer channels and `a` taken from `colorB`);
channels are
combined as floats and truncated to integers, so a result is never rounded
up. Because the result is a color value, it can be passed straight back
into any other mixing function.

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
| `linearMixRatio` | `ratioB → colorA → colorB → color` | Linear interpolation. `0` returns `colorA`, `1` returns `colorB`. |
| `evenMix` | `colorA → colorB → color` | Even 50/50 mix, shorthand for `linearMixRatio 0.5`. |
| `tint` | `ratio → color → color` | Mix a color towards white (`0` is white, `1` is the color). |
| `shade` | `ratio → color → color` | Mix a color towards black (`0` is black, `1` is the color). |
| `multiplyMix` | `colorA → colorB → color` | Multiplicative (subtractive) blend. |
| `screenMix` | `colorA → colorB → color` | Screen (additive) blend. |
| `dodge` | `colorA → colorB → color` | Color dodge; lightens `colorA` by `colorB`. |
| `burn` | `colorA → colorB → color` | Color burn; darkens `colorA` by `colorB`. |

## Examples

```nix
{ config, ... }:
with config.lib.palette;
{
  mixed = linearMixRatio 0.25 "#ff0000" "#0000ff";  # rgb attrset: r = 191, g = 0, b = 63
  even = evenMix "#ff0000" "#0000ff";               # r = 127, g = 0, b = 127
  lighter = tint 0.5 "#808080";                     # r = 191, g = 191, b = 191
  darker = shade 0.5 "#808080";                     # r = 64, g = 64, b = 64
  multiplied = multiplyMix "#ff8000" "#8080ff";     # r = 128, g = 64, b = 0
  screened = screenMix "#ff8000" "#8080ff";         # r = 255, g = 192, b = 255
  dodged = dodge "#808080" "#404040";               # r = 170, g = 170, b = 170
  burned = burn "#808080" "#c0c0c0";                # r = 87, g = 87, b = 87
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
