{ lib, ... }:
let
  writeBabashkaApplication =
    pkgs:
    {
      name,
      text,
      runtimeInputs ? [ ],
    }:
    let
      script = pkgs.writeText "${name}.clj" text;
    in
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        exec ${pkgs.babashka}/bin/bb ${script} "$@"
      '';
      checkPhase = ''
        ${pkgs.clj-kondo}/bin/clj-kondo --lint ${script}
      '';
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.tv-preview-tests = pkgs.runCommand "tv-preview-tests" {
        nativeBuildInputs = with pkgs; [ babashka clj-kondo ];
      } ''
        cp ${./tv/preview.clj} preview.clj
        cp ${./tv/preview-test.clj} preview_test.clj
        clj-kondo --lint preview.clj preview_test.clj
        bb -cp . preview_test.clj
        touch "$out"
      '';
    };

  apps.tv.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (writeBabashkaApplication pkgs {
          name = "tss-preview";
          runtimeInputs = with pkgs; [ coreutils tmux ];
          text = builtins.readFile ./tv/preview.clj;
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
