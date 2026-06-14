{ ... }:
{
  apps.tmux.homeManager =
    { pkgs, ... }:
    let
      # Vendored from https://github.com/Sohalt/write-babashka-application
      writeBabashkaApplication =
        {
          name,
          text,
          runtimeInputs ? [ ],
        }:
        let
          script = pkgs.writeText "script.clj" text;
        in
        pkgs.writeShellApplication {
          inherit name runtimeInputs;
          text = ''
            exec ${pkgs.babashka}/bin/bb ${script} $@
          '';
          checkPhase = ''
            ${pkgs.clj-kondo}/bin/clj-kondo --config '{:linters {:namespace-name-mismatch {:level :off}}}' --lint ${script}
          '';
        };
    in
    {
      home.packages = [
        (writeBabashkaApplication {
          name = "bmm";
          text = builtins.readFile ./tmux/bmm.clj;
          runtimeInputs = with pkgs; [
            git
            tmux
          ];
        })
      ];

      programs.tmux = {
        enable = true;
        escapeTime = 300;
        terminal = "tmux-256color";
        keyMode = "vi";
        extraConfig = ''
          bind C-g display-popup -E -w 85% -h 85% "${pkgs.lazygit}/bin/lazygit"

          set -wg allow-rename on
          set -wg automatic-rename off
        '';
      };
    };
}
