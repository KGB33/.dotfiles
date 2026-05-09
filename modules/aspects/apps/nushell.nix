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
          plugins =
            pkgs.nushellPlugins
            |> lib.filterAttrs (name: value: lib.isDerivation value)
            |> lib.filterAttrs (name: value: !(value.meta.broken or false))
            |> lib.filterAttrs (
              name: value:
              !(lib.elem name [
                "bson"
                "highlight"
              ])
            )
            |> lib.attrValues;
        };
      };
  };
}
