{tv, ...}: {
  programs.television = {
    package = tv;
    enable = true;
    channels = {
      custom = {
        tmux = [
          {
            name = "session select";
            source_command = "tmux ls -F '#{session_name}'";
            preview_command = "tmux ls -F'#{session_id}#{session_name}: #{T:tree_mode_format}'";
          }
        ];
      };
    };
  };
}
