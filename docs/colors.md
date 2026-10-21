# Named colors

`palette.colors` holds colors by meaning instead of index. They are rendered
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
