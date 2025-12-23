{
  lib,
  config,
  ...
}: {
  options.apps.vicinae.enable = lib.mkEnableOption "vicinae" // {default = true;};
  config = lib.mkIf config.apps.vicinae.enable {
    services.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
