if status is-interactive
    fish_vi_key_bindings
    set fish_greeting

    fish_add_path "$HOME/.local/bin"
    fish_add_path "$GOPATH/bin"
    fish_add_path "$CARGO_HOME/bin"

    starship init fish | source
end

if status is-login
    # Launch Hyprland
    if test (tty) = /dev/tty1
        Hyprland
    end
end
