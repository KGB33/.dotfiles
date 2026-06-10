{ lib, ... }:
{
  apps.tv.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "tss-preview";
          runtimeInputs = with pkgs; [
            jq
            tmux
            coreutils
          ];
          text = builtins.readFile ./tv/preview.sh;
        })
      ];

      programs.television = {
        enable = true;
        channels = {
          tss = {
            metadata = {
              name = "tss";
            };
            source = {
              command = "tmux ls -F '#{session_name}'";
              output = "tmux switch -t {}";
            };
            keybindings = {
              ctrl-y = "actions:switch";
            };
            actions.switch = {
              description = "Switch to session";
              command = "tmux switch -t {}";
            };
            preview = {
              command = "tss-preview {}";
            };
          };

          meta = {
            metadata = {
              name = "meta";
            };
            source = {
              command = "tv list-channels";
            };
          };
        };
      };

      programs.tmux.extraConfig = lib.mkAfter "bind t display-popup -E -w 85% -h 85% bash -c 'exec `tv tss`";

    };
}
