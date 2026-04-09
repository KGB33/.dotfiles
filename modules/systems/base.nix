{inputs, ...}: {
  flake.modules.nixos.system-base = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      system-minimal
      podman
      user-kgb33
    ];

    # Bootloader.
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      kernelModules = ["ip_tables" "iptable_nat"];
      extraModulePackages = [];
    };

    services.fwupd.enable = true;

    hardware = {
      bluetooth.enable = true;
      graphics.enable = true;
    };
    services.blueman.enable = true;

    # Sound
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    security.pam.services = {
      hyprlock = {};
    };

    # Shells
    programs.zsh.enable = true;
    programs.fish.enable = true;
  };
}
