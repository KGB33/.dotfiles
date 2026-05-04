let
  installer = variant: {
    nixos =
      { modulesPath, lib, ... }:
      {
        imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-${variant}.nix") ];
      };
  };
in
{
  # make USB/VM installers.
  vm.bootable.provides = {
    tui = installer "minimal";
    gui = installer "graphical-base";
  };
}
