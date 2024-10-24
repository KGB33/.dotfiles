{
  config,
  pkgs,
  lib,
  dagPkgs,
  hmm',
  nasty',
  wezterm',
  ...
}: {
  imports = [
    ./wezterm/wezterm.nix
    ./nushell/nushell.nix
    ./nvim/nvim.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
    ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      alejandra # Nix formatter
      cabal-install
      cargo
      fd
      fzf
      gh
      ghc
      uv
      python313
      gnused
      noto-fonts-color-emoji
      obsidian
      ripgrep
      zig
      (nerdfonts.override {fonts = ["FiraCode"];})
    ]
    ++ [dagPkgs.dagger hmm' nasty'];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
    };
  };

  home.sessionVariables = let
    cfg = config.xdg.configHome;
    data = config.xdg.dataHome;
  in {
    EDITOR = "nvim";
    GNUPGHOME = "${cfg}/gnupg";

    # Docker
    DOCKER_CONFIG = "${cfg}/docker";

    # Go
    GOPATH = "${data}/go";

    # Rust
    CARGO_HOME = "${data}/cargo";
    RUSTUP_HOME = "${data}/rustup";

    NIXOS_OZONE_WL = "1";

    # Misc XDG nonsense
    OPAMROOT = "${data}/opam"; # oCaml pkgs manager
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
    settings = {
      add_newline = true;
      status = {
        pipestatus = true;
        map_symbol = true;
      };
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };

  programs.git = {
    enable = true;
    userEmail = "keltonbassingthwaite@gmail.com";
    userName = "Kelton Bassingthwaite";

    lfs = {
      enable = true;
    };

    difftastic = {
      enable = true;
      display = "inline";
    };

    extraConfig = {
      rerere.enabled = true;
      status = {
        showUntrackedFiles = "all";
      };
      pull = {
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "everforest-dark-hard";
      truecolor = true;
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

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
        river
      end
    '';
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 10;
    };
    themeFile = "everforest_dark_medium";
    # enable_audio_bell = "no";
  };

  programs.tmux = {
    enable = true;
    escapeTime = 300;
    terminal = "screen-256color";
    extraConfig = ''
      set-option -sa terminal-features ',xterm-kitty:RGB'
    '';
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      imports = lib.mkForce ["skins/dark-gruvbox.hjson"];
      verbs = [
        {
          invocation = "edit";
          key = "enter";
          shortcut = "e";
          execution = "nvim +{line} {file}";
          apply_to = "text_file";
          leave_broot = true;
        }
      ];
    };
  };

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "Gruvbox Dark";
    };
  };

  programs.nh = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
