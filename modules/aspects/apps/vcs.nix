{ inputs, lib, ... }:
{
  flake-file.inputs.hunk = {
    url = "github:modem-dev/hunk";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  apps.vcs =
    let
      user' = {
        email = lib.mkDefault "keltonbassingthwaite@gmail.com";
        name = "Kelton Bassingthwaite";
      };
    in
    {
      homeManager =
        { ... }:
        {
          imports = [ inputs.hunk.homeManagerModules.default ];

          programs.hunk = {
            enable = true;
            settings = {
              theme = "terminal";
              agent_notes = true;
            };
          };

          programs.difftastic = {
            enable = true;
            jujutsu.enable = true;
            git = {
              mode = "external";
              enable = true;
            };
          };

          programs.git = {
            enable = true;
            lfs.enable = true;
            signing = {
              format = "ssh";
              key = "~/.ssh/id_ed25519.pub";
              signByDefault = true;
            };
            settings = {
              user = user';

              rerere.enabled = true;
              status = {
                showUntrackedFiles = "all";
              };
              pull = {
                rebase = true;
              };
              push = {
                useForceIfIncludes = true;
              };
              alias = {
                pushf = "push --force-with-lease";
              };
              init = {
                defaultBranch = "main";
              };
              diff."nodiff" = {
                command = "echo Diff Not Shown.";
              };
            };
            attributes = [
              "*.lock diff=nodiff"
              "package-lock.json diff=nodiff"
            ];
          };

          programs.jujutsu = {
            enable = true;

            settings = {
              user = user';
            };
          };
        };
    };
}
