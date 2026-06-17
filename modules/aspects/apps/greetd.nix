{ ... }:
{
  apps.greetd.nixos =
    { pkgs, config, ... }:
    {
      services.greetd = {
        enable = true;
        settings.default_session = {
          user = "greeter";
          command = builtins.concatStringsSep " " [
            "${pkgs.tuigreet}/bin/tuigreet"
            "--time"
            "--remember"
            "--remember-session"
            "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
          ];
        };
      };
    };
}
