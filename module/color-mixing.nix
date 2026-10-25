{ lib }:
let
  formatConversion = import ./color-conversion.nix { inherit lib; };
  formats = import ./color-formats.nix { inherit lib; };
  inherit (formatConversion) convertToColorFormat;
  inherit (formats) generateRGB;
in
lib.makeExtensible (
  self: with self; {

    # Mix ratio (linear)
    # ratioB 0-1 (0 = ColorA, 1 = ColorB)
    linearMixRatio =
      ratioB: colorA: colorB:
      let
        colorA_RGB = convertToColorFormat "rgb" colorA;
        colorB_RGB = convertToColorFormat "rgb" colorB;
      in
      generateRGB (builtins.floor (colorA_RGB.r * (1 - ratioB) + colorB_RGB.r * ratioB)) (builtins.floor (
        colorA_RGB.g * (1 - ratioB) + colorB_RGB.g * ratioB
      )) (builtins.floor (colorA_RGB.b * (1 - ratioB) + colorB_RGB.b * ratioB)) colorB_RGB.a;

    # Even 50/50 mix (linear)
    evenMix = colorA: colorB: linearMixRatio 0.5 colorA colorB;

    # Mix a color towards white (linear)
    # ratio 0-1 (1 = white)
    tint = ratio: color: linearMixRatio ratio "#ffffff" color;

    # Mix a color towards black (linear)
    # ratio 0-1 (1 = black)
    shade = ratio: color: linearMixRatio ratio "#000000" color;

    # Multiply (subtractive) mix
    multiplyMix =
      colorA: colorB:
      let
        colorA_RGB = convertToColorFormat "rgb" colorA;
        colorB_RGB = convertToColorFormat "rgb" colorB;
      in
      generateRGB (builtins.floor (colorA_RGB.r * colorB_RGB.r / 255)) (builtins.floor (
        colorA_RGB.g * colorB_RGB.g / 255
      )) (builtins.floor (colorA_RGB.b * colorB_RGB.b / 255)) colorB_RGB.a;

    # Screen (additive) mix
    screenMix =
      colorA: colorB:
      let
        colorA_RGB = convertToColorFormat "rgb" colorA;
        colorB_RGB = convertToColorFormat "rgb" colorB;
      in
      generateRGB (builtins.floor (255 - (255 - colorA_RGB.r) * (255 - colorB_RGB.r) / 255)) (
        builtins.floor
          (255 - (255 - colorA_RGB.g) * (255 - colorB_RGB.g) / 255)
      ) (builtins.floor (255 - (255 - colorA_RGB.b) * (255 - colorB_RGB.b) / 255)) colorB_RGB.a;

    # Color dodge (lightening)
    dodge =
      colorA: colorB:
      let
        colorA_RGB = convertToColorFormat "rgb" colorA;
        colorB_RGB = convertToColorFormat "rgb" colorB;
      in
      generateRGB
        (
          if colorB_RGB.r == 255 then
            255
          else
            lib.min 255 (builtins.floor (colorA_RGB.r * 255 / (255 - colorB_RGB.r)))
        )
        (
          if colorB_RGB.g == 255 then
            255
          else
            lib.min 255 (builtins.floor (colorA_RGB.g * 255 / (255 - colorB_RGB.g)))
        )
        (
          if colorB_RGB.b == 255 then
            255
          else
            lib.min 255 (builtins.floor (colorA_RGB.b * 255 / (255 - colorB_RGB.b)))
        )
        colorB_RGB.a;

    # Color burn (darkening)
    burn =
      colorA: colorB:
      let
        colorA_RGB = convertToColorFormat "rgb" colorA;
        colorB_RGB = convertToColorFormat "rgb" colorB;
      in
      generateRGB
        (
          if colorB_RGB.r == 0 then
            0
          else
            lib.max 0 (builtins.floor (255 - (255 - colorA_RGB.r) * 255 / colorB_RGB.r))
        )
        (
          if colorB_RGB.g == 0 then
            0
          else
            lib.max 0 (builtins.floor (255 - (255 - colorA_RGB.g) * 255 / colorB_RGB.g))
        )
        (
          if colorB_RGB.b == 0 then
            0
          else
            lib.max 0 (builtins.floor (255 - (255 - colorA_RGB.b) * 255 / colorB_RGB.b))
        )
        colorB_RGB.a;
  }
)
