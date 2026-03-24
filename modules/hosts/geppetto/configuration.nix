{self, ...}: {
  flake.modules.nixos.geppetto = {pkgs, ...}: {
    imports = [
      self.modules.nixos.sops
      self.modules.nixos.system-base
      ../../../components/wireguard.nix
      # ../../components/steam.nix # TODO: Add steam module.
    ];

    networking = {
      hostName = "geppetto";
      firewall = {
        allowedTCPPorts = [];
      };
    };
    boot.initrd.kernelModules = ["amdgpu"];
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
  };
}
