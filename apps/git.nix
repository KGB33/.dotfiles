{
  config,
  lib,
  ...
}: {
  options.apps.git.enable = lib.mkEnableOption "git" // {default = true;};

  config = lib.mkIf config.apps.git.enable {
    programs.git = {
      enable = true;
      userEmail = lib.mkDefault "keltonbassingthwaite@gmail.com";
      userName = "Kelton Bassingthwaite";

      lfs = {
        enable = true;
      };

      difftastic = {
        enable = true;
        display = "inline";
      };

      extraConfig = {
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
    xdg.configFile."git/attributes" = {
      text = ''
        *.lock diff=nodiff
        package-lock.json diff=nodiff
      '';
    };
  };
}
