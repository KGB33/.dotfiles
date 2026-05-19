{
  lib,
  apps,
  den,
  ...
}:
{
  apps.nushell-login = {
    includes =
      let
        unused = den.lib.take.unused __findFile;
        __findFile = unused den.lib.__findFile;
      in
      [
        apps.nushell
        (<den/user-shell> "bash")
      ];
    nixos =
      { pkgs, ... }:
      {
        environment.shells = [ pkgs.nushell ];
        programs.bash.interactiveShellInit = ''
          if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
            exec nu
          fi
        '';
      };
  };
  apps.nushell-darwin.homeManager =
    { ... }:
    {
      programs.zsh = {
        enable = true;
        initExtra = ''
          if [[ ! $(ps -T -o "comm" | tail -n +2 | grep "nu$") && -z $ZSH_EXECUTION_STRING ]]; then
            if [[ -o login ]]; then
              LOGIN_OPTION='--login'
            else
              LOGIN_OPTION=""
            fi
            exec nu "$LOGIN_OPTION"
          fi
        '';
      };
    };

  apps.nushell = {
    includes = [
      apps.shell
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.shell.enableNushellIntegration = true;
        programs.nushell = {
          enable = true;
          settings = {
            edit_mode = "vi";
            keybindings = [
              {
                name = "insert_last_command";
                modifier = "alt";
                keycode = "char_l";
                mode = [
                  "emacs"
                  "vi_insert"
                  "vi_normal"
                ];
                event = {
                  send = "ExecuteHostCommand";
                  cmd = "commandline edit --insert (history | last | get command)";
                };
              }
            ];
          };
          plugins =
            pkgs.nushellPlugins
            |> lib.filterAttrs (name: value: lib.isDerivation value)
            |> lib.filterAttrs (name: value: !(value.meta.broken or false))
            |> lib.filterAttrs (
              name: value:
              !(lib.elem name [
                "desktop_notifications"
                "bson"
                "highlight"
              ])
            )
            |> lib.attrValues;
        };
      };
  };
}
