{inputs, ...}: {
  flake-file.inputs.vicinae.url = "github:vicinaehq/vicinae";

  flake.modules.homeManager.vicinae = {...}: {
    imports = [inputs.vicinae.homeManagerModules.default];

    services.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
