{ components, ... }:
{
  den.aspects.blue = {
    includes = [
      components.container
      components.framework-13
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
        boot.loader.systemd-boot = {
          enable = true;
          configurationLimit = 16;
        };

        networking = {
          useNetworkd = true;
          networkmanager.enable = false;
          hostName = "blue";
          wireless.iwd.enable = true;
        };

        systemd.network = {
          enable = true;
          networks."10-wlan0" = {
            matchConfig.Name = "wlan0";
            networkConfig.DHCP = "yes";
          };
        };

        networking.wireguard.interfaces.wg0 = {
          ips = [ "10.0.4.4/32" ];
          privateKeyFile = "/home/kgb33/.config/wireguard/blue-private.key";
          peers = [
            {
              # tower
              publicKey = "coWFYrpcI/JoHrvo41yJizU+PoE7zqQCf0lfrQDSwnA=";
              presharedKeyFile = "/home/kgb33/.config/wireguard/blue-preshared.key";
              allowedIPs = [
                "10.0.4.1/32"
                "10.0.9.100/32"
              ];
              endpoint = "kgb33.dev:51823";
              persistentKeepalive = 25;
            }
          ];
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
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/6505c892-0491-48ef-937d-65e1dc6963c5";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/7D6A-5D1E";
          fsType = "vfat";
        };

        swapDevices = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
