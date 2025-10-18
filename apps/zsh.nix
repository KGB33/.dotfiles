{
  config,
  lib,
  ...
}: {
  options.apps.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.apps.zsh.enable {
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      defaultKeymap = "viins";
      syntaxHighlighting.enable = true;
      initExtraFirst = builtins.readFile ./zsh/zshrc;
      shellAliases = {
        ll = "eza -F -lbh $argv";
        obs = "nvim `fd . --extension md ~/notes/ObsNotes/ | fzf`";
        ng = "npx @angular/cli";
      };
    };
  };
}
