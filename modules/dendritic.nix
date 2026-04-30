{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
  flake-file.inputs.den.url = lib.mkDefault "github:vic/den";
  flake-file.formatter = {pkgs, ...}: pkgs.alejandra;
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
}
