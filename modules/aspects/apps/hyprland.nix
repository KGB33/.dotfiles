{ apps, inputs, ... }:
{
  flake-file.inputs.hyprland = {
    url = "github:hyprwm/Hyprland";
  };

  apps.hyprland = {
    includes = with apps; [
      wezterm
      noctalia
    ];

    nixos =
      { pkgs, ... }:
      let
        hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      in
      {
        nix.settings = {
          substituters = [ "https://hyprland.cachix.org" ];
          trusted-substituters = [ "https://hyprland.cachix.org" ];
          trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

        };

        services.displayManager.sessionPackages = [
          (pkgs.runCommand "hyprland-session" { passthru.providedSessions = [ "hyprland" ]; } ''
            mkdir -p $out/share/wayland-sessions
            cat > $out/share/wayland-sessions/hyprland.desktop <<EOF
            [Desktop Entry]
            Name=Hyprland
            Exec=${hyprland}/bin/start-hyprland
            Type=Application
            EOF
          '')
        ];
      };

    homeManager =
      { pkgs, lib, ... }:
      let
        hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portal = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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
        home.packages = with pkgs; [
          kitty
          grim
          slurp
          wl-clipboard
          playerctl
        ];

        xdg.configFile."hypr/my-cfg.lua".source = compileFennel "hyprland-fnl" (
          builtins.readFile ./hyprland/my-cfg.fnl
        );
        wayland.windowManager.hyprland = {
          package = hyprland;
          portalPackage = portal;
          enable = true;
          extraConfig = ''
            require("my-cfg");
          '';
        };
      };
  };
}
