# Color mixing

`palette.nix` ships a small set of pure color-mixing helpers alongside the
palette itself. They are exposed on `config.lib.palette` and are handy for
deriving a border, shadow, or highlight color from the colors in your scheme.

Every helper takes hex strings in `#RRGGBB` form and returns a new `#RRGGBB`
string. Channels are combined as floats and truncated to integers, so a result
is never rounded up.

```nix
{ config, ... }:
with config.lib.palette;
with config.palette.hex;
{
  # Mix a scheme color halfway towards white.
  some.option = tint 0.5 base00.normal;
}
```

## Functions

| Function | Signature | Description |
| --- | --- | --- |
| `linearMixRatio` | `ratioB → colorA → colorB → hex` | Linear interpolation. `ratioB` of `0` returns `colorA`, `1` returns `colorB`. |
| `evenMix` | `colorA → colorB → hex` | Even 50/50 mix, shorthand for `linearMixRatio 0.5`. |
| `tint` | `ratio → color → hex` | Mix a color towards white (`ratio` of `1` is white). |
| `shade` | `ratio → color → hex` | Mix a color towards black (`ratio` of `1` is black). |
| `multiplyMix` | `colorA → colorB → hex` | Multiplicative (subtractive) blend. |
| `screenMix` | `colorA → colorB → hex` | Screen (additive) blend. |
| `dodge` | `colorA → colorB → hex` | Color dodge; lightens `colorA` by `colorB`. |
| `burn` | `colorA → colorB → hex` | Color burn; darkens `colorA` by `colorB`. |

## Linear mixes

```nix
config.lib.palette.linearMixRatio 0.25 "#ff0000" "#0000ff"  # "#bf003f"
config.lib.palette.evenMix "#ff0000" "#0000ff"              # "#7f007f"
```

`ratioB` is clamped by construction to the range between the two inputs, so any
value between `0` and `1` stays within `#000000`…`#ffffff`.

## Tint and shade

`tint` and `shade` are the same linear mix, just anchored to white or black:

```nix
config.lib.palette.tint 0.5 "#808080"   # "#bfbfbf"
config.lib.palette.shade 0.5 "#808080"  # "#404040"
```

## Blend modes

`multiplyMix`, `screenMix`, `dodge`, and `burn` implement the usual compositing
blends, treating `colorA` as the base and `colorB` as the blend layer:

```nix
config.lib.palette.multiplyMix "#ff8000" "#8080ff"  # "#804000"
config.lib.palette.screenMix "#ff8000" "#8080ff"    # "#ffc0ff"
config.lib.palette.dodge "#808080" "#404040"        # "#aaaaaa"
config.lib.palette.burn "#808080" "#c0c0c0"         # "#575757"
```

`dodge` and `burn` are clamped to `#000000`…`#ffffff`, and their degenerate
division cases are guarded: dodging with a fully white blend yields white, and
burning with a fully black blend yields black.

## Chaining with `|>`

Every helper takes more than just the piped color, so each stage wraps the call
in a lambda whose last argument is the running color. Nix's `|>` then feeds the
result of one stage into the next:

```nix
{ config, ... }:
let
  mix = config.lib.palette;
in
config.palette.hex.base00.normal
|> (c: mix.tint 0.2 c)          # lift it towards white
|> (c: mix.shade 0.1 c)         # pull it back down a touch
|> (c: mix.multiplyMix c "#88aaff")  # tint it blue
```

The same works for the blend modes, using the running color as the base:

```nix
"#ff8000"
|> (c: mix.screenMix c "#303030")
|> (c: mix.dodge c "#202020")
```

if the function takes a color as the last formal parameter then there will be no need to turn the next in the chain to a function.

```nix
{ config, ... }:
with config.lib.palette;
config.palette.hex.base00.normal
|> tint 0.2
|> shade 0.1
|> multiplyMix "#88aaff"
```
