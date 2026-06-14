{ lib, ... }:
{
  apps.shell.homeManager =
    { pkgs, ... }:
    let
      atuinPtyProxyInit = pkgs.runCommand "atuin-pty-proxy-init.nu" { } ''
        HOME=$TMPDIR ${pkgs.atuin}/bin/atuin pty-proxy init nu > $out
      '';
    in
    {

      programs.atuin = {
        enable = true;
        daemon.enable = true;
      };

      programs.nushell.configFile.text = lib.mkMerge [
        (lib.mkBefore ''
          source ${atuinPtyProxyInit}
        '')
        (lib.mkAfter
          # nu
          ''
            $env.config.hooks = ($env.config.hooks? | default {})
            $env.config.hooks.pre_execution = (
              $env.config.hooks.pre_execution? | default [] | append {||
                let parts = (commandline | split row " " | where ($it | str length) > 0)
                let name = ($parts | get 0? | default "" | path basename)
                if ($name | is-not-empty) and not ($name | str starts-with "#") {
                  print -rn $"(char -i 27)k($name)(char -i 27)(char -i 92)"
                }
              }
            )
            $env.config.hooks.pre_prompt = (
              $env.config.hooks.pre_prompt? | default [] | append {||
                let name = ($env.PWD | path basename)
                print -rn $"(char -i 27)k($name)(char -i 27)(char -i 92)"
              }
            )
          ''
        )
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.starship = {
        enable = true;
        presets = [
          "nerd-font-symbols"
          "pure-preset"
        ];

      };

      programs.carapace = {
        enable = true;
      };

    };
}
