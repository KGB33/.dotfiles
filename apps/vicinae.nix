{
  lib,
  pkgs,
  config,
  ...
}: {
  services.vicinae = {
    enable = true;
    autoStart = false;
  };

  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae server daemon";
      Documentation = ["https://docs.vicinae.com"];
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      BindsTo = ["graphical-session.target"];
    };
    Service = {
      EnvironmentFile = lib.mkForce (pkgs.writeText "vicinae-env" ''
        USE_LAYER_SHELL=1
        WAYLAND_DISPLAY=wayland-1
      '');
      Type = "simple";
      ExecStart = "${lib.getExe' config.services.vicinae.package "vicinae"} server";
      Restart = "always";
      RestartSec = 5;
      KillMode = "process";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
