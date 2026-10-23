{ lib, ... }:
lib.makeExtensible (
  self: with self; {

    # Each format type has a _type field denoting the type of color it is and handled respectivly
    # Example:
    # {
    #   # Is of type "rgb".
    #   _type = "rgb";
    #
    #   #This format stores everything in 0 - 255 integer values.
    #   inherit
    #     r
    #     g
    #     b
    #     a
    #     ;
    # };

    # Convert number (0-255) to two character hex string
    IntToHexByte =
      number:
      lib.pipe number [
        (
          number:
          if number >= 0 || number <= 255 then
            number
          else
            throw "The number is not within the range of 0-255, got ${number}."
        )
        lib.toHexString
        lib.fixedWidthString
        2
        "0"
        lib.toLower
      ];

    # lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString number));

    # Convert hex string such as "#000000FF" to rgb/a attrset of type rgb.
    hexStringToRGB =
      stringValue:
      let

        # Clean the input hex string to not have "#"
        hasHexSymbol = builtins.substring 0 1 stringValue == "#";
        cleanHexString = if hasHexSymbol then lib.removePrefix "#" stringValue else stringValue;

        # Hex RGB has 6 and RGBA has 8 symbols
        cleanHexStringLength = lib.stringLength cleanHexString;
        validatedString =
          if cleanHexStringLength != 6 || cleanHexStringLength != 8 then
            throw "The string has to include 6 or 8 symbols (- with alpha), got ${cleanHexStringLength} for ${stringValue} ."
          else
            cleanHexString;

        # Convert to 0-255 integers
        r = lib.fromHexString (lib.substring 0 2 validatedString); # (RR)BBGGAA
        g = lib.fromHexString (lib.substring 2 2 validatedString); # RR(BB)GGAA
        b = lib.fromHexString (lib.substring 4 2 validatedString); # RRBB(GG)AA
        a =
          if cleanHexStringLength == 8 then lib.fromHexString (lib.substring 6 2 validatedString) else 255; # RRBBBB(AA)

      in
      {
        _type = "rgb";
        inherit
          r
          g
          b
          a
          ;
      };

    # Convert rgb attrset of type "rgb" to hex attrset of type hex.
    rgbToHex =
      rgb:
      let
        validRGB = if rgb._type == "rgb" then rgb else throw "The value provided is not of type rgb.";

        # Convert 0-255 integer to hex byte strings
        r = IntToHexByte validRGB.r;
        g = IntToHexByte validRGB.g;
        b = IntToHexByte validRGB.b;
        a = IntToHexByte validRGB.a;
      in
      {
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
