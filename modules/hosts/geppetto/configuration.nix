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

    system.stateVersion = "23.11"; # Don't change
  };
}
