{ lib, pkgs }:
let
  formatConversion = import ./color-conversion.nix { inherit lib; };
  parsing = import ./parsing.nix { inherit lib pkgs; };

in
lib.makeExtensible (
  self: with self; {

    inherit (parsing) parseFromFile;
    inherit (formatConversion)
      hexStringToRGB
      rgbValueToHex
      hexValueToRGB
      intToHexByte
      hexOpacityToFloat
      floatOpacityToHex
      convertToColorFormat
      ;

    # Constructs an attrset
    # {
    #   base<N> = { _type = "rgb"; ...}
    # }
    loadBaseColors =
      source:
      lib.pipe source [
        (source: if builtins.isAttrs source then source else parseFromFile source)
        (parsed: parsed.palette or parsed)
        (colors: lib.filterAttrs (name: _: lib.hasPrefix "base" (lib.toLower name)) colors)
        (lib.mapAttrs (_: toString)) # make sure the value is a string
        (lib.mapAttrs' (name: value: lib.nameValuePair (lib.toLower name) value))
        (lib.mapAttrs' (name: value: lib.nameValuePair name (hexStringToRGB value)))
      ];

    loadNamedColors =
      source:
      lib.pipe source [
        (source: if builtins.isAttrs source then source else parseFromFile source)
        (parsed: parsed.palette or parsed)
        (lib.mapAttrs' (name: value: lib.nameValuePair name (hexStringToRGB value)))
      ];

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
        defaultOpacity ? 1.0,
      }:
      let
        # can be path to file or attrset of colors
        baseColors = loadBaseColors colors;
        builtPalette = buildNamedPalette {
          nestedColors = baseColors;
          inherit defaultOpacity;
        };
      in
      {
        hex = builtPalette.hex;
        rgb = builtPalette.rgb;
      };

    buildNamedPalette =
      {
        nestedColors,
        defaultOpacity ? 1.0,
      }:
      let
        # Walk every nesting level, applying `f` to each color leaf. A
        # value of type rgb or hex is a leaf,
        walk =
          f: set:
          lib.mapAttrs (
            name: value:
            let
              isColourFormat = lib.elem (value._type or "") [
                "rgb"
                "hex"
              ];
            in
            if builtins.isAttrs value && !isColourFormat then walk f value else f name value
          ) set;

        # Hex format
        hexTree = walk (
          name: color:
          let
            colorHex = convertToColorFormat "hex" color;
            r = colorHex.r;
            g = colorHex.g;
            b = colorHex.b;
            alpha = if colorHex.a != null then colorHex.a else floatOpacityToHex defaultOpacity;
          in
          {
            normal = "#${r}${g}${b}";
            withoutHash = "${r}${g}${b}";
            withOpacity = "#${r}${g}${b}${alpha}";
            inherit r g b;
            opacity = alpha;
          }
        ) nestedColors;

        # RGB format
        rgbTree = walk (
          name: color:
          let
            colorRGB = convertToColorFormat "rgb" color;
            alpha = if colorRGB.a != null then colorRGB.a else defaultOpacity;
          in
          {
            normal = "rgb(${toString colorRGB.r}, ${toString colorRGB.g}, ${toString colorRGB.b})";
            withOpacity = "rgba(${toString colorRGB.r}, ${toString colorRGB.g}, ${toString colorRGB.b}, ${toString alpha})";
            r = colorRGB.r;
            g = colorRGB.g;
            b = colorRGB.b;
            opacity = alpha;
          }
        ) nestedColors;

      in
      {
        hex = hexTree;
        rgb = rgbTree;
      };

  }
)
