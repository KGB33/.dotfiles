{config, ...}: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "viins";
    syntaxHighlighting.enable = true;
    initExtraFirst = builtins.readFile ./zshrc;
    shellAliases = {
      ll = "eza -F -lbh $argv";
      obs = "nvim `fd . --extension md ~/notes/ObsNotes/ | fzf`";
      ng = "npx @angular/cli";
    };
  };
}
