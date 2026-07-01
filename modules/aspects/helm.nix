{ components, ... }:
{
  den.aspects.helm = {
    includes = [
      components.printing
    ];
    nixos =
      {
        lib,
        modulesPath,
        config,
        pkgs,
        ...
      }:
      {
        # Set the next reboot to boot into EFI entry 0000 (Windows, for gaming).
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "gametime" ''
            sudo ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0000
          '')
        ];

        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
        };

        boot.loader.systemd-boot = {
          enable = true;
          configurationLimit = 16;
        };

        networking = {
          useNetworkd = true;
          networkmanager.enable = false;
          hostName = "helm";
          wireless.iwd.enable = true;
        };

        systemd.network = {
          enable = true;
          networks."05-eth0" = {
            matchConfig.Name = "enp74s0";
            networkConfig.DHCP = "yes";
          };
        };

        hardware.graphics.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };

        # Hardware configuration
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = [
          "thunderbolt"
          "xhci_pci"
          "nvme"
          "ahci"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/e0451e40-4302-4c7c-af5d-0716d8480b2c";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/1E8B-4762";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };

        swapDevices = [ ];

        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp74s0.useDHCP = lib.mkDefault true;
        # networking.interfaces.wlp73s0.useDHCP = lib.mkDefault true;

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
