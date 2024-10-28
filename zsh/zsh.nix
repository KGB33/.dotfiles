{...}: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    defaultKeymap = "viins";
    syntaxHighlighting.enable = true;
    initExtraFirst = builtins.readFile ./zshrc;
    shellAliases = {
      ll = "eza -F -lbh $argv";
      obs = "nvim `fd . --extension md ~/notes/ObsNotes/ | fzf`";
    };
  };

  programs = {
    atuin.enableZshIntergration = true;
    broot.enableZshIntergration = true;
    direnv.enableZshIntergration = true;
    eza.enableZshIntergration = true;
    starship.enableZshIntergration = true;
  };
}
