{ lib, pkgs }:
lib.makeExtensible (self: {

  # Converters
  convertYamlFileToJsonFile =
    file:
    (pkgs.runCommandLocal "from-yaml.json"
      {
        nativeBuildInputs = [ pkgs.yq-go ];
        src = file;
      }
      ''
        yq -p yaml -o json "$src" > "$out"
      ''
    );

  # Parsers
  fromYaml =
    path:
    path
    |> self.convertYamlFileToJsonFile
    |> builtins.readFile
    |> builtins.fromJSON;

  fromJson = path: builtins.fromJSON (builtins.readFile path);
  fromToml = path: builtins.fromTOML (builtins.readFile path);

  fileParsers = {
    yaml = self.fromYaml;
    yml = self.fromYaml;
    json = self.fromJson;
    toml = self.fromToml;
  };

  #
  fileExtensionFromPath =
    path:
    path
    |> toString
    |> baseNameOf
    |> (lib.splitString ".")
    |> lib.last
    |> lib.toLower;

  parseFromFile =
    filePath:
    filePath
    |> self.fileExtensionFromPath
    |> (
      fileExtension:
      self.fileParsers.${fileExtension}
        or (throw "palette.nix: unsupported filetype '.${fileExtension}' in ${toString filePath}")
    )
    |> (parser: parser filePath);

})
