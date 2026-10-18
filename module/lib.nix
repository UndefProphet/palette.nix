{ lib, pkgs }:
let
  utility = import ./utility.nix { inherit lib; };
  parsing = import ./parsing.nix { inherit lib pkgs; };

in
lib.makeExtensible (
  self: with self; {

    inherit (parsing) parseFromFile;
    inherit (utility) toHexByte;

    # Constructs an attrset
    # {
    #   base<N> = "#<hex color>"
    # }
    loadRawColors =
      source:
      source
      |> (source: if builtins.isAttrs source then source else parseFromFile source)
      |> (parsed: parsed.palette or parsed)
      |> (colors: lib.filterAttrs (name: _: lib.hasPrefix "base" name) colors)
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
        colors:
        lib.filterAttrs (
          name: _:
          builtins.elem name [
            "variant"
            "author"
            "name"
          ]
        ) colors
      )
      |> (lib.mapAttrs (_: toString)); # make sure the value is a string

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
      }:
      let
        # can be path to file or attrset of colors
        metaInformation = loadMeta colors;
        author = metaInformation.author or null;
        variant = if metaInformation ? variant then lib.toLower metaInformation.variant else null;

        # can be path to file or attrset of colors
        hexColors = loadRawColors colors;

        rgbComponents =
          hexColors
          |> lib.mapAttrs (
            _: hex:
            let
              # Convert hex color to 0-255 rgb values
              clean = lib.removePrefix "#" hex;
              r = lib.fromHexString (lib.substring 0 2 clean); # (00)0000
              g = lib.fromHexString (lib.substring 2 2 clean); # 00(00)00
              b = lib.fromHexString (lib.substring 4 2 clean); # 0000(00)
            in
            {
              inherit r;
              inherit g;
              inherit b;
            }
          );

        hexWithAlpha =
          rgbComponents
          |> lib.mapAttrs (
            name: components:
            let
              # TODO: Fix by clamping
              a = builtins.floor (opacity * 255.0 + 0.5);
            in
            "#${toHexByte components.r}${toHexByte components.g}${toHexByte components.b}${toHexByte a}"
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
                normal = normal;
                withOpacity = withOpacity;
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
        inherit author variant;
      };

  }
)
