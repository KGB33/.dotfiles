{ inputs, ... }:
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
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

      programs.claude-code = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

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
          tui = "fullscreen";
          theme = "light";
          remoteControlAtStartup = false;
          model = "claude-fable-5[1m]";
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
