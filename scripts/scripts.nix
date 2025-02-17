{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "tss";
      runtimeInputs = [gum];
      text = builtins.readFile ./tmux_session_select.sh;
    })
  ];
}
