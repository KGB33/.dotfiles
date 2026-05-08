{ lib, ... }:
{
  apps.tv.homeManager = {
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
