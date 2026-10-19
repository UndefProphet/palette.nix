{ lib }:
let
  utility = import ./utility.nix { inherit lib; };
  inherit (utility) hexToRGB RGBToHex;
in
lib.makeExtensible (
  self: with self; {

    # Mix ratio (linear)
    # ratioB 0-1 (0 = ColorA, 1 = ColorB)
    # ColorA (HEX)
    # ColorB (HEX)
    linearMixRatio =
      ratioB: colorA: colorB:
      let
        colorA_RGB = hexToRGB colorA;
        colorB_RGB = hexToRGB colorB;

        newColor_RGB = {
          r = builtins.floor (colorA_RGB.r * (1 - ratioB) + colorB_RGB.r * ratioB);
          g = builtins.floor (colorA_RGB.g * (1 - ratioB) + colorB_RGB.g * ratioB);
          b = builtins.floor (colorA_RGB.b * (1 - ratioB) + colorB_RGB.b * ratioB);
        };

        newColor = RGBToHex newColor_RGB;
      in
      newColor;

    # Even 50/50 mix (linear)
    # ColorA (HEX)
    # ColorB (HEX)
    evenMix = colorA: colorB: linearMixRatio 0.5 colorA colorB;

    # Mix a color towards white (linear)
    # ratio 0-1 (1 = white)
    # Color (HEX)
    tint = ratio: color: linearMixRatio ratio color "#ffffff";

    # Mix a color towards black (linear)
    # ratio 0-1 (1 = black)
    # Color (HEX)
    shade = ratio: color: linearMixRatio ratio color "#000000";

    # Multiply (subtractive) mix
    # ColorA (HEX)
    # ColorB (HEX)
    multiplyMix =
      colorA: colorB:
      let
        colorA_RGB = hexToRGB colorA;
        colorB_RGB = hexToRGB colorB;

        newColor_RGB = {
          r = builtins.floor (colorA_RGB.r * colorB_RGB.r / 255);
          g = builtins.floor (colorA_RGB.g * colorB_RGB.g / 255);
          b = builtins.floor (colorA_RGB.b * colorB_RGB.b / 255);
        };

        newColor = RGBToHex newColor_RGB;
      in
      newColor;

    # Screen (additive) mix
    # ColorA (HEX)
    # ColorB (HEX)
    screenMix =
      colorA: colorB:
      let
        colorA_RGB = hexToRGB colorA;
        colorB_RGB = hexToRGB colorB;

        newColor_RGB = {
          r = builtins.floor (255 - (255 - colorA_RGB.r) * (255 - colorB_RGB.r) / 255);
          g = builtins.floor (255 - (255 - colorA_RGB.g) * (255 - colorB_RGB.g) / 255);
          b = builtins.floor (255 - (255 - colorA_RGB.b) * (255 - colorB_RGB.b) / 255);
        };

        newColor = RGBToHex newColor_RGB;
      in
      newColor;

    # Color dodge (lightening)
    # ColorA (HEX) base
    # ColorB (HEX) blend
    dodge =
      colorA: colorB:
      let
        colorA_RGB = hexToRGB colorA;
        colorB_RGB = hexToRGB colorB;

        newColor_RGB = {
          r = if colorB_RGB.r == 255 then 255 else lib.min 255 (builtins.floor (colorA_RGB.r * 255 / (255 - colorB_RGB.r)));
          g = if colorB_RGB.g == 255 then 255 else lib.min 255 (builtins.floor (colorA_RGB.g * 255 / (255 - colorB_RGB.g)));
          b = if colorB_RGB.b == 255 then 255 else lib.min 255 (builtins.floor (colorA_RGB.b * 255 / (255 - colorB_RGB.b)));
        };

        newColor = RGBToHex newColor_RGB;
      in
      newColor;

    # Color burn (darkening)
    # ColorA (HEX) base
    # ColorB (HEX) blend
    burn =
      colorA: colorB:
      let
        colorA_RGB = hexToRGB colorA;
        colorB_RGB = hexToRGB colorB;

        newColor_RGB = {
          r = if colorB_RGB.r == 0 then 0 else lib.max 0 (builtins.floor (255 - (255 - colorA_RGB.r) * 255 / colorB_RGB.r));
          g = if colorB_RGB.g == 0 then 0 else lib.max 0 (builtins.floor (255 - (255 - colorA_RGB.g) * 255 / colorB_RGB.g));
          b = if colorB_RGB.b == 0 then 0 else lib.max 0 (builtins.floor (255 - (255 - colorA_RGB.b) * 255 / colorB_RGB.b));
        };

        newColor = RGBToHex newColor_RGB;
      in
      newColor;

  }
)
