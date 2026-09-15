{ inputs, ... }:
{

  flake-file.inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
  };

  components.framework.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-hardware.nixosModules.framework-16-7040-amd ];
      services.fwupd.enable = true;

      services.fprintd.enable = true;

      environment.systemPackages = with pkgs; [
        framework-tool
        framework-tool-tui
        inputmodule-control
      ];

      hardware.inputmodule.enable = true;

    };

  components.framework-13.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-hardware.nixosModules.framework-11th-gen-intel ];
      services.fwupd.enable = true;

      services.fprintd.enable = true;

      environment.systemPackages = with pkgs; [
        framework-tool
        framework-tool-tui
      ];
    };
}
