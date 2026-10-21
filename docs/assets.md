# Assets

`palette.fonts`, `palette.cursors` and `palette.icons` only store what you
declare. Nothing is installed or enabled for you. Use them to keep a theme's
assets in one place and read them back from `config.palette`.

```nix
{
  palette = {
    fonts = {
      sizes = {
        terminal = 9.0;
        desktop = 10.0;
        popups = 11.0;
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMonoNL Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
    };

    cursors = {
      main = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
      large = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 32;
      };
    };

    icons = {
      main = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus Icon Theme";
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };
      monochrome = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        dark = "Adwaita";
        light = "Adwaita";
      };
    };
  };
}
```

Read them back with e.g.

```nix
{ config, ... }:
with config.palette;
{
  terminal = fonts.sizes.terminal;
  monospace = fonts.monospace.name;
  cursor = cursors.main.size;
  icon = icons.main.dark;
}
```

`fonts` takes any number of named fonts plus a set of named `sizes`;
`cursors` and `icons` take any number of named entries.
