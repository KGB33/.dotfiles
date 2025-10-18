{
  lib,
  config,
  pkgs,
  ...
}: {
  options.apps.fish.enable = lib.mkEnableOption "fish" // {default = true;};

  config = lib.mkIf config.apps.fish.enable {
    programs.fish = {
      enable = true;
      functions = {
        fish_command_not_found = ''echo "Command `$argv` not found."'';
        ll_ = ''eza -F -lbh $argv'';
        obs = ''command nvim (${pkgs.fd} . --extention md ~/notes/obsidianVault | ${pkgs.fzf})'';
        venv = ''${builtins.readFile ./fish/functions/venv.fish}'';
        update = ''${builtins.readFile ./fish/functions/update.fish}'';
        dagvenv = ''${builtins.readFile ./fish/functions/dagvenv.fish}'';
        sealSecret = ''${builtins.readFile ./fish/functions/sealSecret.fish}'';
      };
      interactiveShellInit = ''
        fish_vi_key_bindings
        set fish_greeting

        fish_add_path "$HOME/.local/bin"
        fish_add_path "$GOPATH/bin"
        fish_add_path "$CARGO_HOME/bin"
      '';
      loginShellInit = ''
        if test (tty) = /dev/tty1
          Hyprland
        end
      '';
    };
  };
}
