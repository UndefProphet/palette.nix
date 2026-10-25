# Named colors

`palette.colors` holds colors by meaning instead of index. Colors may be written with or without the leading `#` (`"#cdd6f4"` or
`"cdd6f4"`) and may include an alpha channel (`"#cdd6f4d9"`), which overrides
`palette.opacity` for that color. They are rendered
exactly like the scheme colors, so `config.palette.colors.hex.<name>` and
`config.palette.colors.rgb.<name>` carry the same attributes (see
[Output shape](./options.md#output-shape)).

```nix
{
  palette.colors =
    with config.lib.palette;
    {
    text = "#cdd6f4";
    background = getBase 2;
    border = "#45475a";
  };
}
```

Groups nest to any depth and are mirrored in the path:

```nix
{
  palette.colors = {
    text = "#cdd6f4";
    programming = {
      text = "#cdd6f4";
      text-light = "#cdd6f4";
      editor = { background = "#1e1e2e"; };
    };
  };
}
```

```nix
{ config, ... }:
with config.palette.colors.hex;
programming.editor.background.normal
```

## Helper

`config.lib.palette.getBase` returns the plain hex of a scheme color, by string
or integer index:

```nix
{ config, ... }:
with config.lib.palette;
{
  byString = getBase "0D";  # "#89b4fa"
  byInt = getBase 13;       # "#89b4fa"
}
```

Integer indices start at `0`; set
`palette._startIncrementFromOneGetBase = true` to count from `1`. Any other
argument type throws.

## Color generators

`config.lib.palette` also exposes functions to build color values directly.
They are useful wherever a color is needed in a specific format, for example
as input to the [mixing helpers](./color-mixing.md):

```nix
{ config }:
with config.lib.palette;
{
  # rgb color value: channels are 0-255 integers, a is a 0.0-1.0 float
  # or null for unset.
  someColor = generateRGB 30 30 46 null;

  # hex color value: channels and a are two character hex byte strings;
  # a may be null.
  otherColor = generateHex "1e" "1e" "2e" null;
}
```

Both return a color value attrset carrying a `_type` attribute (`"rgb"` or
`"hex"`) alongside `r`, `g`, `b` and `a`. Color values are accepted by every
function that takes a color, including `palette.colors` entries and the
mixing helpers.
