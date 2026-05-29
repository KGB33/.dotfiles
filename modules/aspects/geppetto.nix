{ components, ... }:
{
  den.aspects.geppetto = {
    includes = [
      components.container
      components.framework
      components.printing
    ];
    nixos =
      {
        lib,
        modulesPath,
        config,
        ...
      }:
      {
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
          useNetworkd = false;
          networkmanager.enable = false;
          hostName = "geppetto";
          wireless.iwd.enable = true;
        };

        systemd.network = {
          enable = true;
          networks."10-wlan0" = {
            matchConfig.Name = "wlan0";
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
          "nvme"
          "xhci_pci"
          "thunderbolt"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/5eccc2a8-24c1-44d7-b4d2-16fc8081986d";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/AB01-D778";
          fsType = "vfat";
        };

        swapDevices = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
