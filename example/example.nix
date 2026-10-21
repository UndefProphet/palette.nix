{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.palette-nix.nixosModules.default
  ];

  palette = with config.lib.palette; {
    enable = true;
    colorscheme = ./exampleScheme.yaml;
    opacity = 0.75;

    icons = {
      main = {
        name = "Papirus Icon Theme";
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Dark";
        light = "Papirus-Light"; # Dark mode seems to not be used sometimes.
      };

      secondTheme = {
        name = "Papirus Icon Theme";
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Light"; # Dark mode seems to not be used sometimes.
        light = "Papirus-Dark";
      };
    };

    cursors = {

      main = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      someOtherUsage = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

    };

    # Define different font types and sizes for different purposes.
    fonts = {
      sizes =
        let
          size = 10.0;
        in
        {
          terminal = 9.0;
          applications = size;
          desktop = size;
          popups = size;
        };

      sansSerif = {
        name = "JetBrainsMonoNL Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };

      serif = {
        name = "JetBrainsMonoNL Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };

      monospace = {
        name = "JetBrainsMonoNL Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
    };

    # There are different ways of grouping the colors based on needs and usage!
    colors = {

      # Basic mnemonic
      mnemonic = {
        background = getBase 0;
        lighter-background = getBase 1;
        selection-background = getBase 2;
        comments = getBase 3;
        dark-foreground = getBase 4;
        foreground = getBase 5;
        light-foreground = getBase 6;
        lightest-foreground = getBase 7;
        red = getBase 8;
        orange = getBase 9;
        yellow = getBase 10;
        green = getBase 11;
        cyan = getBase 12;
        blue = getBase 13;
        purple = getBase 14;
        brown = getBase 15;
      };

      # Grouping
      terminal = {
        background = getBase 0;
        lighter-background = getBase 1;
        selection-background = getBase 2;
        comments = getBase 3;
        suggestion = getBase 3 |> tint 0.55;
        dark-foreground = getBase 4;
        foreground = getBase 5;
        light-foreground = getBase 6;
        lightest-foreground = getBase 7;
        red = getBase 8;
        orange = getBase 9;
        yellow = getBase 10;
        green = getBase 11;
        cyan = getBase 12;
        blue = getBase 13;
        purple = getBase 14;
        brown = getBase 15;
      };

      # Arbitrary amount of nesting
      ui = {
        text = getBase 2;
        window = {
          background = getBase 0;
          lighter-background = getBase 1;
        };
      };

    };

  };
}
