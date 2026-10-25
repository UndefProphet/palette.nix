{ lib, config }:
let
  conversion = import ./color-conversion.nix { inherit lib; };
in
lib.makeExtensible (self: {

  # Get a base color
  getBase =
    hexIndex:
    let
      incrementFromOne = config.palette._startIncrementFromOneGetBase;

      color =
        if builtins.typeOf hexIndex == "string" then
          # Sanitize the hex index by user
          config.palette.baseColors.hex."base${lib.toLower hexIndex}".normal
        else if builtins.typeOf hexIndex == "int" then
          let
            # Handle change of start position of index if set by user
            hexByteIndex = conversion.intToHexByte (if incrementFromOne then (hexIndex - 1) else hexIndex);
          in
          config.palette.baseColors.hex."base${hexByteIndex}".normal
        else
          throw "Not a valid base type for index. Should be either string as hex value or an int. Got: ${builtins.typeOf hexIndex}";
    in
    color;

})
