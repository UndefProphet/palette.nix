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
      source
      |> (source: if builtins.isAttrs source then source else parseFromFile source)
      |> (parsed: parsed.palette or parsed)
      |> (colors: lib.filterAttrs (name: _: lib.hasPrefix "base" (lib.toLower name)) colors)
      # Formatting and validation
      |> (lib.mapAttrs (_: toString)) # make sure the value is a string
      |> lib.mapAttrs' (name: value: lib.nameValuePair (lib.toLower name) value )
      |> (lib.mapAttrs (
        colorName: hexcolor:
        validateHexColor {
          color = hexcolor;
          name = colorName;
        }
      ));

    loadNamed =
      source:
      source
      |> (source: if builtins.isAttrs source then source else parseFromFile source)
      |> (parsed: parsed.palette or parsed)
      # Formatting and validation
      |> (lib.mapAttrs (_: toString)) # make sure the value is a string
      |> (lib.mapAttrs (
        colorName: hexcolor:
        validateHexColor {
          color = hexcolor;
          name = colorName;
        }
      ));

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
      source
      |> (source: if builtins.isAttrs source then source else parseFromFile source)
      |> (
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
      |> (lib.mapAttrs (_: toString)); # make sure the value is a string

    buildMeta =
      file:
      let
        metaInformation = loadMeta file;
      in
      {
        author = metaInformation.author or null;
        variant = if metaInformation ? variant then lib.toLower metaInformation.variant else null;
      };

    # Produces a palette for each type of color expression with an opacity variant
    # Example:
    # {
    # hex = {
    #   base<N> = {
    #      normal = "#<hex>"
    #      r = "11"
    #      ...
    #   };
    #   rgb = { ... };
    # }
    buildPalette =
      {
        colors,
        opacity ? 1.0,
        skipBaseCheck ? false,
      }:
      let
        # can be path to file or attrset of colors
        hexColors = if skipBaseCheck then loadNamed colors else loadRawColors colors;

        rgbComponents = hexColors |> lib.mapAttrs (_: hex: hexToRGB hex);

        hexWithAlpha =
          rgbComponents
          |> lib.mapAttrs (
            name: components:
            RGBAToHex {
              r = components.r;
              g = components.g;
              b = components.b;
              a = builtins.floor (opacity * 255.0 + 0.5);
            }
          );

        rgbString =
          rgbComponents
          |> lib.mapAttrs (name: comp: "rgb(${toString comp.r}, ${toString comp.g}, ${toString comp.b})");

        rgbaString =
          rgbComponents
          |> lib.mapAttrs (
            name: comp: "rgba(${toString comp.r}, ${toString comp.g}, ${toString comp.b}, ${toString opacity})"
          );

        # Sort the name into a list [ "base00" "base01" ... ].
        baseNames = lib.attrNames hexColors;

        hexEntries =
          baseNames
          |> map (
            name:
            let
              components = rgbComponents.${name};
              normal = hexColors.${name};
              withOpacity = hexWithAlpha.${name};
            in
            {
              name = name;
              value = {
                inherit normal;
                inherit withOpacity;
                opacity = toHexByte (builtins.floor (opacity * 255.0 + 0.5));
                r = toHexByte components.r;
                g = toHexByte components.g;
                b = toHexByte components.b;
              };
            }
          )
          |> lib.listToAttrs;

        rgbEntries =
          baseNames
          |> map (
            name:
            let
              comp = rgbComponents.${name};
              normal = rgbString.${name};
              withOpacity = rgbaString.${name};
            in
            {
              name = name;
              value = {
                normal = normal;
                withOpacity = withOpacity;
                opacity = toString opacity;
                r = comp.r;
                g = comp.g;
                b = comp.b;
              };
            }
          )
          |> lib.listToAttrs;

      in
      {
        hex = hexEntries;
        rgb = rgbEntries;
      };

  }
)
