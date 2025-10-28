{
  lib,
  config,
  ...
}: {
  options.apps.nyxt.enable = lib.mkEnableOption "Nyxt" // {default = true;};

  config = lib.mkIf config.apps.nyxt.enable {
    programs.nyxt = {
      enable = true;
    };
  };
}
