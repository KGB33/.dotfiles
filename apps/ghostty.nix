{
  lib,
  config,
  ...
}: {
  options.apps.ghostty.enable = lib.mkEnableOption "ghostty" // {default = true;};

  config = lib.mkIf config.apps.ghostty.enable {
    programs.ghostty = {
      enable = true;
    };
  };
}
