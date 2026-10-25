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
    #     a # Unset values are null
    #     ;
    # };

    # Convert number (0-255) to two character hex string
    intToHexByte =
      number:
      lib.pipe number [
        (
          number:
          if number >= 0 && number <= 255 then
            number
          else
            throw "The number is not within the range of 0-255, got ${toString number}."
        )
        lib.toHexString
        (lib.fixedWidthString 2 "0")
        lib.toLower
      ];

    # Hex opacity (two character hex byte) to rgb opacity (0.0-1.0 float) and vice versa
    hexOpacityToFloat = hexByte: (lib.fromHexString hexByte) / 255.0;
    floatOpacityToHex = rgbOpacity: intToHexByte (builtins.floor (rgbOpacity * 255.0 + 0.5));

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
          if cleanHexStringLength != 6 && cleanHexStringLength != 8 then
            throw "The string has to include 6 or 8 symbols (- with alpha), got ${toString cleanHexStringLength} for ${stringValue} ."
          else
            cleanHexString;

        # Convert to 0-255 integers
        r = lib.fromHexString (lib.substring 0 2 validatedString); # (RR)BBGGAA
        g = lib.fromHexString (lib.substring 2 2 validatedString); # RR(BB)GGAA
        b = lib.fromHexString (lib.substring 4 2 validatedString); # RRBB(GG)AA
        a =
          if cleanHexStringLength == 8 then hexOpacityToFloat (lib.substring 6 2 validatedString) else null; # RRBBBB(AA)

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

    # Convert hex attrset of type "hex" to rgb/a attrset of type rgb.
    hexValueToRGB =
      hex:
      let
        validRGB = if hex._type == "hex" then hex else throw "The value provided is not of type hex.";

        # Convert hex byte strings to 0-255 integers
        r = lib.fromHexString validRGB.r;
        g = lib.fromHexString validRGB.g;
        b = lib.fromHexString validRGB.b;
        a = if validRGB.a == null then null else hexOpacityToFloat validRGB.a;
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
    rgbValueToHex =
      rgb:
      let
        validRGB = if rgb._type == "rgb" then rgb else throw "The value provided is not of type rgb.";

        # Convert 0-255 integers to hex byte strings
        r = intToHexByte validRGB.r;
        g = intToHexByte validRGB.g;
        b = intToHexByte validRGB.b;
        a = if validRGB.a == null then null else floatOpacityToHex validRGB.a;
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

    convertToColorFormat =
      format: color:
      let
        invalidType = throw "The color is not of a valid type, got ${builtins.typeOf color}.";
        toRGB =
          if builtins.typeOf color == "string" then
            hexStringToRGB color
          else if (color._type or "") == "rgb" then
            color
          else if (color._type or "") == "hex" then
            hexValueToRGB color
          else
            invalidType;
        toHex =
          if builtins.typeOf color == "string" then
            rgbValueToHex (hexStringToRGB color)
          else if (color._type or "") == "hex" then
            color
          else if (color._type or "") == "rgb" then
            rgbValueToHex color
          else
            invalidType;
      in
      if format == "hex" then
        toHex
      else if format == "rgb" then
        toRGB
      else
        throw ''Unknown color format ${format}, expected "hex" or "rgb".'';

  }
)
