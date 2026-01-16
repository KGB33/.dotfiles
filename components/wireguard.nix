{
  lib,
  config,
  pkgs,
  ...
}: {
  options.apps.wireguard.enable = lib.mkEnableOption "wireguard"; # // {default = pkgs.stdenv.isLinux;};

  config = lib.mkIf config.apps.wireguard.enable {
    sops = {
      age.keyFile = "/home/kgb33/.config/sops/age/keys.txt";
      # TODO: Make these system agnostic
      # Pre-TODO: Buy another laptop
      defaultSopsFile = ./wireguard/keys.yaml;
      secrets = let
        permissions = {
          owner = "systemd-network";
          group = "systemd-network";
          mode = "0400";
        };
      in {
        geppetto-psk = permissions;
        geppetto-prv = permissions;
      };
    };
    systemd.network = {
      # Don't enable here, Systemd-networkd needs to be enabled in the main system config
      # enable = true;
      networks."50-wg0" = {
        matchConfig.Name = "wg0";
        address = ["10.0.4.2/32"];
      };
      netdevs."50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };
        wireguardConfig = {
          FirewallMark = 42;
          # ListenPort = 51820; # is this needed?
          PrivateKeyFile = config.sops.secrets.geppetto-prv.path;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            PublicKey = "coWFYrpcI/JoHrvo41yJizU+PoE7zqQCf0lfrQDSwnA=";
            PresharedKeyFile = config.sops.secrets.geppetto-psk.path;
            AllowedIPs = [
              "10.0.4.0/24"
              "10.0.9.0/24"
            ];
            Endpoint = "kgb33.dev:51823";
          }
        ];
      };
    };
  };
}
