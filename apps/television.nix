{
  lib,
  config,
  pkgs,
  ...
}: let
  tvOn = config.programs.television.enable;
  tv = pkgs.television;
in {
  programs.television = {
    package = tv;
    enable = true;
    settings = {
      tick_rate = 60;
      default_channel = "meta";
      ui = {
        use_nerd_font_icons = true;
      };
      keybindings = {
        "}" = "scroll_preview_half_page_down";
        "{" = "scroll_preview_half_page_up";
      };
      shell_integration = {
        channel_triggers = {
          "meta" = ["tv"];
          "alias" = ["alias" "unalias"];
          "env" = ["export" "unset"];
          "dirs" = ["cd" "ls" "rmdir"];
          "git-diff" = ["git add" "git restore"];
          "git-branch" = [
            "git checkout"
            "git switch"
            "git branch"
            "git merge"
            "git rebase"
            "git pull"
            "git push"
          ];
          "git-log" = ["git log" "git show"];
          "docker-images" = ["docker run"];
          "git-repos" = ["git clone"];
        };
        keybindings = {
          smart_autocomplete = "ctrl-t";
        };
      };
    };
    channels = {
      tss = {
        metadata = {name = "tss";};
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
        metadata = {name = "meta";};
        source = {
          command = "tv list-channels";
        };
      };
    };
  };

  programs.nix-search-tv = {
    enable = true;
  };
}
