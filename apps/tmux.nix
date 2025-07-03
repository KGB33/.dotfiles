{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    escapeTime = 300;
    terminal = "tmux-256color";
    extraConfig = ''
      set-option -sa terminal-features 'xterm-256color:RGB'
      bind C-g display-popup -w 85% -h 85% "${pkgs.lazygit}/bin/lazygit"
    '';
  };
}
