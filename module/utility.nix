{ lib }:
lib.makeExtensible (self: {

  # Convert number (0-255) to hex
  toHexByte = number: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString number));
})
