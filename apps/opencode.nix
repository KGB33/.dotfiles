{
  lib,
  config,
  ...
}: {
  options.apps.opencode.enable = lib.mkEnableOption "opencode" // {default = true;};

  config = lib.mkIf config.apps.opencode.enable {
    programs.opencode = {
      enable = true;
      settings = {
        autoshare = false;
        autoupdate = false;
        mcp = {
          container-use = {
            type = "local";
            command = ["container-use" "stdio"];
            enabled = true;
          };
        };
      };
    };
  };
}
