{lib, ...}: let
  apps =
    ./.
    |> builtins.readDir
    |> builtins.attrNames
    |> builtins.filter (f: lib.strings.hasSuffix ".nix" f)
    |> builtins.filter (f: f != "default.nix")
    |> builtins.map (e: ./${e});
in {
  imports = apps;
}
