{ lib, config }:
let
  utility = import ./utility.nix { inherit lib; };
in
lib.makeExtensible (self: {

  # Get a base color
  getBase =
    hexIndex:
    let
      color =
        if builtins.typeOf hexIndex == "string" then
          config.palette.baseColors.hex."base${lib.toLower hexIndex}".normal
        else if builtins.typeOf hexIndex == "int" then
          config.palette.baseColors.hex."base${utility.toHexByte hexIndex}".normal
        else
          throw "Not a valid base type for index. Should be either string as hex value or an int. Got: ${builtins.typeOf hexIndex}";
    in
    color;

})
