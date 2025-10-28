{
  config,
  lib,
  ...
}: {
  options.apps.git.enable = lib.mkEnableOption "git" // {default = true;};

  config = lib.mkIf config.apps.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          email = lib.mkDefault "keltonbassingthwaite@gmail.com";
          name = "Kelton Bassingthwaite";
        };
      };

      lfs = {
        enable = true;
      };

      settings = {
        rerere.enabled = true;
        status = {
          showUntrackedFiles = "all";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
        diff."nodiff" = {
          command = "echo Diff Not Shown.";
        };
      };
    };
    programs.difftastic = {
      enable = true;
      options.display = "inline";
      git = {
        diffToolMode = true;
        enable = true;
      };
    };
    xdg.configFile."git/attributes" = {
      text = ''
        *.lock diff=nodiff
        package-lock.json diff=nodiff
      '';
    };
  };
}
