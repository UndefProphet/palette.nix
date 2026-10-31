# Example

A complete `palette` setup: a scheme with opacity, fonts, cursors, icons and
named colors in three flavours (flat, grouped, nested).

Use it from a flake by handing the flake input to the module as an argument:

```nix
{
  outputs = { nixpkgs, palette-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inputs = { inherit palette-nix; };
      };
      modules = [ ./example/example.nix ];
    };
  };
}
```

The scheme files next to it show the supported formats: `exampleScheme.yaml`,
`exampleScheme.json`, `exampleScheme.toml` (colors under a `palette` key) and
`exampleFlatScheme.yml` (colors at the top level).
