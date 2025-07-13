{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "tss";
      runtimeInputs = [gum];
      text = builtins.readFile ./tmux_session_select.sh;
    })
    (writeShellApplication {
      name = "tmux-tree";
      text = builtins.readFile ./tmux-tree.sh;
    })
    (writeShellApplication {
      name = "faff";
      runtimeInputs = [curl jq bc uutils-coreutils-noprefix];
      text = builtins.readFile ./faff.sh;
    })
  ];
}
