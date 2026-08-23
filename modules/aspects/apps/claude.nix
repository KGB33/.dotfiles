{ inputs, ... }:
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };
    vibes = {
      url = "github:KGB33/vibes";
      flake = false;
    };
  };

  apps.claude.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      tmuxStatusHook = {
        hooks = [
          {
            type = "command";
            command = "${config.home.homeDirectory}/.claude/hooks/tmux-status";
          }
        ];
      };
    in
    {
      den.unfree.predicates = [ "claude-code" ];

      home.sessionVariables.OBSIDIAN_VAULT_PATH = "${config.home.homeDirectory}/Notes";

      programs.claude-code = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

        plugins = {
          frontend-design = "${inputs.claude-plugins-official}/plugins/frontend-design";
          playground = "${inputs.claude-plugins-official}/plugins/playground";
          # Manual Cartographer/Scout workflow backed by durable Obsidian maps.
          workflow = "${inputs.vibes}/plugins/workflow";
        };

        hooks.tmux-status = ''
          #!${pkgs.bash}/bin/bash
          export PATH=${
            lib.makeBinPath (
              with pkgs;
              [
                jq
                tmux
                coreutils
              ]
            )
          }:$PATH
        ''
        + builtins.readFile ./claude/tmux-status.sh;

        settings = {
          theme = "light";
          remoteControlAtStartup = false;
          model = "claude-opus-5[1m]";
          hooks = {
            PostToolUse = [
              (tmuxStatusHook // { matcher = "*"; })
            ];
            SessionStart = [ tmuxStatusHook ];
            UserPromptSubmit = [ tmuxStatusHook ];
            Notification = [ tmuxStatusHook ];
            Stop = [ tmuxStatusHook ];
            SessionEnd = [ tmuxStatusHook ];
          };
        };
      };
    };
}
