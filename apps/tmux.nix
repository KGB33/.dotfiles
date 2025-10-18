{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.programs.tmux.enable {
    programs.tmux = {
      escapeTime = 300;
      terminal = "tmux-256color";
      keyMode = "vi";
      extraConfig = let
        tss =
          if config.programs.television.enable
          then "bash -c 'exec `tv tss`'"
          else "tss";
      in ''
            bind C-g display-popup -E -w 85% -h 85% "${pkgs.lazygit}/bin/lazygit"
            bind t display-popup -E -w 85% -h 85% "${tss}"
            # Cursed regex from here: https://jyn.dev/how-i-use-my-terminal/#search-all-scrollback-for-filenames
            bind-key f copy-mode \; send-keys -X search-backward \
        '(^|/|\<|[[:space:]"])((\.|\.\.)|[[:alnum:]~_"-]*)((/[][[:alnum:]_.#$%&+=@"-]+)+([/ "]|\.([][[:alnum:]_.#$%&+=@"-]+(:[0-9]+)?(:[0-9]+)?)|[][[:alnum:]_.#$%&+=@"-]+(:[0-9]+)(:[0-9]+)?)|(/[][[:alnum:]_.#$%&+=@"-]+){2,}([/ "]|\.([][[:alnum:]_.#$%&+=@"-]+(:[0-9]+)?(:[0-9]+)?)|[][[:alnum:]_.#$%&+=@"-]+(:[0-9]+)(:[0-9]+)?)?|(\.|\.\.)/([][[:alnum:]_.#$%&+=@"-]+(:[0-9]+)?(:[0-9]+)?))'

      '';
    };
  };
}
