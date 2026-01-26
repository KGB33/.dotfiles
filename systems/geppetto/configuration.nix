{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./network.nix
    ./hardware-configuration.nix
    ../../components/steam.nix
  ];

  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelPatches = [
    # TODO: Remove this when dagger fixes their stuff
    # https://github.com/dagger/dagger/issues/11694
    {
      name = "netfilter-xtables-legacy";
      patch = null;
      extraConfig = ''
        NETFILTER_XTABLES_LEGACY y
      '';
    }
  ];
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
