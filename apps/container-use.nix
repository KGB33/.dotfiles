{
  lib,
  config,
  dagger',
  ...
}: {
  options = {
    apps.container-use.enable = lib.mkEnableOption "container-use";
  };
  config = lib.mkIf config.apps.container-use.enable {
    home.packages = [dagger'.container-use];
  };
}
