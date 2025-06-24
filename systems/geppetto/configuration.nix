{lib, ...}: {
  imports = [
    ./network.nix
    ./hardware-configuration.nix
  ];

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
}
