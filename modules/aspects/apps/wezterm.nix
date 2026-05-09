{ ... }:
{

  apps.wezterm.homeManager =
    { pkgs, ... }:
    let
      compileFennel =
        name: src:
        pkgs.runCommand name
          {
            fnlSrc = src;
          }
          ''
            ${pkgs.luaPackages.fennel}/bin/fennel --compile - <<< "$fnlSrc" > "$out"
          '';

    in
    {
      xdg.configFile."wezterm/fnl-conf.lua".source = compileFennel "wez-config" (
        builtins.readFile ./wezterm/config.fnl
      );
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          return require("fnl-conf").apply(config);
        '';
      };
    };
}
