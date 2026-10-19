{ lib }:
lib.makeExtensible (
  self: with self; {

    # Convert number (0-255) to hex
    toHexByte = number: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString number));

    hexToRGB =
      hex:
      let
        # Convert hex color to 0-255 rgb values
        cleanHex =
          if lib.stringLength hex != 7 then
          throw "Hex color with alpha must have 7 characters, got ${hex}"
        else
            (lib.removePrefix "#" hex);

        r = lib.fromHexString (lib.substring 0 2 cleanHex); # (00)0000
        g = lib.fromHexString (lib.substring 2 2 cleanHex); # 00(00)00
        b = lib.fromHexString (lib.substring 4 2 cleanHex); # 0000(00)
      in
      {
        inherit r;
        inherit g;
        inherit b;
      };

    # Convert hex color to 0-255 rgba values
    hexToRGBA =
      hex:
      let
        cleanHex =
          if lib.stringLength hex != 9 then
          throw "Hex color with alpha must have 9 characters, got ${hex}"
        else
            (lib.removePrefix "#" hex);

        r = lib.fromHexString (lib.substring 0 2 cleanHex); # (00)000AA
        g = lib.fromHexString (lib.substring 2 2 cleanHex); # 00(00)00AA
        b = lib.fromHexString (lib.substring 4 2 cleanHex); # 0000(00)AA
        a = lib.fromHexString (lib.substring 6 2 cleanHex); # 000000(AA)
      in
      {
        inherit r;
        inherit g;
        inherit b;
        inherit a;
      };

    RGBToHex = rgb: "#${toHexByte rgb.r}${toHexByte rgb.g}${toHexByte rgb.b}";
    RGBAToHex = rgba: "#${toHexByte rgba.r}${toHexByte rgba.g}${toHexByte rgba.b}${toHexByte rgba.a}";
  }
)
