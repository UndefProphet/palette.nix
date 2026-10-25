{ lib, ... }:
lib.makeExtensible (
  self: with self; {

    # Generate an rgb color value: channels are 0-255 integers, a is a
    # 0.0-1.0 float or null.
    generateRGB = r: g: b: a: {
      _type = "rgb";
      inherit
        r
        g
        b
        a
        ;
    };

    # Generate a hex color value: channels and a are two character hex
    # byte strings, a may be null.
    generateHex = r: g: b: a: {
      _type = "hex";
      inherit
        r
        g
        b
        a
        ;
    };

  }
)
