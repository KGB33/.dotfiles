{
  lib,
  config,
  pkgs,
  ...
}: {
  options.apps.fish.enable = lib.mkEnableOption "fish" // {default = true;};

  config = lib.mkIf config.apps.fish.enable {
    programs.fish = {
      enable = true;
      functions = {
        fish_command_not_found = ''echo "Command `$argv` not found."'';
        ll_ = ''eza -F -lbh $argv'';
        obs = ''command nvim (${pkgs.fd}/bin/fd . --extension md ~/Notes/ | ${pkgs.fzf}/bin/fzf)'';
        venv = ''${builtins.readFile ./fish/functions/venv.fish}'';
        update = ''${builtins.readFile ./fish/functions/update.fish}'';
        dagvenv = ''${builtins.readFile ./fish/functions/dagvenv.fish}'';
        sealSecret = ''${builtins.readFile ./fish/functions/sealSecret.fish}'';
      };
      interactiveShellInit = ''
        fish_vi_key_bindings
        set fish_greeting


        function __ssh_agent_is_started -d "check if ssh agent is already started"
              if begin; test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"; end
                  source $SSH_ENV > /dev/null
              end

              if test -z "$SSH_AGENT_PID"
                  return 1
              end

              ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep -q ssh-agent
              #pgrep ssh-agent
              return $status
          end


          function __ssh_agent_start -d "start a new ssh agent"
              ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
              chmod 600 $SSH_ENV
              source $SSH_ENV > /dev/null
              true  # suppress errors from setenv, i.e. set -gx
          end


          function fish_ssh_agent --description "Start ssh-agent if not started yet, or uses already started ssh-agent."
              if test -z "$SSH_ENV"
                  set -xg SSH_ENV $HOME/.ssh/environment
              end

              if not __ssh_agent_is_started
                  __ssh_agent_start
              end
          end

        fish_ssh_agent

        fish_add_path "$HOME/.local/bin"
        fish_add_path "$GOPATH/bin"
        fish_add_path "$CARGO_HOME/bin"
      '';
      loginShellInit = ''
      '';
    };
  };
}
