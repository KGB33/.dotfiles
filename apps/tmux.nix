{
  pkgs,
  config,
  ...
}: {
  programs.tmux = {
    enable = true;
    escapeTime = 300;
    terminal = "tmux-256color";
    extraConfig = let
      tss =
        if config.programs.television.enable
        then "tv tss"
        else "tss";
    in ''
      set-option -sa terminal-features 'xterm-256color:RGB'
      bind C-g display-popup -E -w 85% -h 85% "${pkgs.lazygit}/bin/lazygit"
      bind t display-popup -E -w 85% -h 85% "${tss}"
    '';
  };
}
