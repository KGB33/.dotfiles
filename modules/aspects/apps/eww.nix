{ ... }:
{
  apps.eww.homeManager = { ... }: {
    programs.eww = {
      enable = true;
      systemd.enable = true;
      scssConfig = builtins.readFile ./eww/eww.scss;
      yuckConfig = builtins.readFile ./eww/eww.yuck;
    };
  };
}
