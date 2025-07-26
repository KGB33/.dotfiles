{
  lib,
  config,
  pkgs,
  tv,
  ...
}: let
  tvOn = config.programs.television.enable;
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
  };

  home.file = let
    prefix = ".config/television/cable";
    formatter = pkgs.formats.toml {};
  in {
    "${prefix}/tss.toml" = {
      enable = tvOn;
      source = formatter.generate "tss.toml" {
        metadata = {name = "tss";};
        source = {command = "tmux ls -F '#{session_name}'";};
      };
    };
    "${prefix}/meta.toml" = {
      enable = tvOn;
      source = formatter.generate "meta.toml" {
        metadata = {name = "meta";};
        source = {
          command = "tv list-channels";
        };
      };
    };
  };
  home.activation =
    lib.mkIf tvOn
    {
      televisionSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${tv}/bin/tv update-channels
      '';
    };
}
