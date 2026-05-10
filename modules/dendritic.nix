{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.flake-file.url = "github:denful/flake-file";
  flake-file.inputs.den.url = lib.mkDefault "github:denful/den";
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];
}
