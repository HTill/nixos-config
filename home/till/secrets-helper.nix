{ pkgs, ... }:

let
  loadSecrets = path:
    let
      yamlContent = builtins.readFile path;
      jsonContent = pkgs.runCommand "secrets-json" {
        nativeBuildInputs = [ pkgs.yq ];
      } ''
        yq eval -o=json "${yamlContent}" > $out
      '';
      secrets = builtins.fromJSON (builtins.readFile jsonContent);
    in
      secrets;
in
{
  secrets = loadSecrets ./secrets.yaml;
}
