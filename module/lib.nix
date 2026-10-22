{ lib, pkgs }:
let
  utility = import ./utility.nix { inherit lib; };
  parsing = import ./parsing.nix { inherit lib pkgs; };

in
lib.makeExtensible (
  self: with self; {

    inherit (parsing) parseFromFile;
    inherit (utility)
      toHexByte
      hexToRGB
      RGBAToHex
      ;

    # Constructs an attrset
    # {
    #   base<N> = "#<hex color>"
    # }
    loadRawColors =
      source:
      lib.pipe source [
        (source: if builtins.isAttrs source then source else parseFromFile source)
        (parsed: parsed.palette or parsed)
        (colors: lib.filterAttrs (name: _: lib.hasPrefix "base" (lib.toLower name)) colors)
        #Formatting and validation
        (lib.mapAttrs (_: toString)) # make sure the value is a string
        (lib.mapAttrs' (name: value: lib.nameValuePair (lib.toLower name) value))
        (lib.mapAttrs (
          colorName: hexcolor:
          validateHexColor {
            color = hexcolor;
            name = colorName;
          }
        ))
      ];

    loadNamed =
      source:
      lib.pipe source [
        (source: if builtins.isAttrs source then source else parseFromFile source)
        (parsed: parsed.palette or parsed)
        # Formatting and validation
        (lib.mapAttrs (_: toString)) # make sure the value is a string
        (lib.mapAttrs (
          colorName: hexcolor:
          validateHexColor {
            color = hexcolor;
            name = colorName;
          }
        ))
      ];

    validateHexColor =
      {
        color,
        name ? null,
      }:
      let
        length = builtins.stringLength color;
      in
      if length < 7 then
        throw "Hex color ${name} must be at least 7 characters long, got ${toString length}."
      else if length > 7 then
        builtins.warn "Hex color ${name} is longer than 7 characters." (builtins.substring 0 7 color)
      else
        color;

    loadMeta =
      source:
      lib.pipe source [
        (source: if builtins.isAttrs source then source else parseFromFile source)
        (
          meta:
          lib.filterAttrs (
            name: _:
            builtins.elem name [
              "variant"
              "author"
              "name"
            ]
          ) meta
        )
        (lib.mapAttrs (_: toString)) # make sure the value is a string
      ];

    buildMeta =
      file:
      let
        metaInformation = loadMeta file;
      in
      {
        author = metaInformation.author or null;
        variant = if metaInformation ? variant then lib.toLower metaInformation.variant else null;
      };

    buildPalette =
      {
        colors,
        opacity ? 1.0,
      }:
      let
        # can be path to file or attrset of colors
        baseColors = loadRawColors colors;
        builtPalette = buildNamedPalette {
          nestedColors = baseColors;
          inherit opacity;
        };
      in
      {
        hex = builtPalette.hex;
        rgb = builtPalette.rgb;
      };

    buildNamedPalette =
      {
        nestedColors,
        opacity ? 1.0,
      }:
      let
        alpha = builtins.floor (opacity * 255.0 + 0.5);

        # Walk every nesting level, applying `f` to each hex string leaf.
        walk =
          f: set:
          lib.mapAttrs (name: value: if builtins.isAttrs value then walk f value else f name value) set;

        hexTree = walk (
          name: hex:
          let
            color = validateHexColor {
              color = hex;
              name = name;
            };
            colorRGB = hexToRGB color;
          in
          {
            normal = color;
            withoutHash = lib.removePrefix "#" color;
            withOpacity = RGBAToHex {
              inherit (colorRGB) r g b;
              a = alpha;
            };
            opacity = toHexByte alpha;
            r = toHexByte colorRGB.r;
            g = toHexByte colorRGB.g;
            b = toHexByte colorRGB.b;
          }
        ) nestedColors;

        rgbTree = walk (
          name: hex:
          let
            color = validateHexColor {
              color = hex;
              name = name;
            };
            colorRGB = hexToRGB color;
          in
          {
            normal = "rgb(${toString colorRGB.r}, ${toString colorRGB.g}, ${toString colorRGB.b})";
            withOpacity = "rgba(${toString colorRGB.r}, ${toString colorRGB.g}, ${toString colorRGB.b}, ${toString opacity})";
            opacity = toString opacity;
            r = colorRGB.r;
            g = colorRGB.g;
            b = colorRGB.b;
          }
        ) nestedColors;

      in
      {
        hex = hexTree;
        rgb = rgbTree;
      };

  }
)
