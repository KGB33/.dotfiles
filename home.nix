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
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kgb33";
  home.homeDirectory = "/home/kgb33";

  imports = [
    ./wezterm/wezterm.nix
    ./nushell/nushell.nix
    ./sway/sway.nix
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
      freecad
      brightnessctl
      cabal-install
      fd
      fzf
      gh
      ghc
      grim
      hyprlock
      impala
      nh
      prusa-slicer
      slurp
      uv
      noto-fonts-color-emoji
      obsidian
      ripgrep
      wl-clipboard
      xdg-utils
      zig
      (nerdfonts.override {fonts = ["FiraCode"];})
    ]
    ++ [dagPkgs.dagger hmm' nasty'];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/hypr/hypridle.conf".source = hypr/hypridle.conf;
    ".config/hypr/hyprlock.conf".source = hypr/hyprlock.conf;
    ".config/hypr/hyprpaper.conf".source = hypr/hyprpaper.conf;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
    };
  };

  xdg = {
    enable = true;
    portal = {
      config.common.default = "*"; # Just use the first one found.
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-wlr];
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

  programs.fuzzel = {
    enable = true;
    # settings = {};
  };

  wayland.windowManager.river = {
    enable = true;
    systemd.enable = true;
    settings = {
      declare-mode = ["Display"];
      map = {
        normal =
          {
            "-repeat None XF86AudioRaiseVolume" = "spawn 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+'";
            "-repeat None XF86AudioLowerVolume" = "spawn 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-'";
            "-repeat None XF86MonBrightnessUp" = "spawn 'brightnessctl s +5%'";
            "-repeat None XF86MonBrightnessDown" = "spawn 'brightnessctl s 5%-'";
            "None XF86AudioMute" = "spawn 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";

            # Spawns
            "Super R" = "spawn fuzzel";
            "Alt L" = "spawn hyprlock";
            "Super C" = "close";
            "Super+Shift S" = "spawn 'grim -g \"$(slurp -d)\" - | wl-copy'";

            # Meta
            "Super M" = "exit";
            "Super D" = "enter-mode Display";

            # Window Focus
            "Super H" = "focus-view left";
            "Super J" = "focus-view down";
            "Super K" = "focus-view up";
            "Super L" = "focus-view right";
            "Super N" = "focus-view next";
            "Super P" = "focus-view previous";

            # Window Movement
            "Super+Shift H" = "swap left";
            "Super+Shift J" = "swap down";
            "Super+Shift K" = "swap up";
            "Super+Shift L" = "swap right";
            "Super+Shift N" = "swap next";
            "Super+Shift P" = "swap previous";
            "Super Z" = "zoom";
          }
          // (
            # Tags
            let
              pow = exp:
                if exp == 0
                then 1
                else 2 * pow (exp - 1);
              str = builtins.toString;
            in
              builtins.listToAttrs (
                builtins.concatLists [
                  (builtins.genList (x: {
                      name = "Super ${str x}";
                      value = "set-focused-tags ${str (pow x)}";
                    })
                    9)
                  (builtins.genList (x: {
                      name = "Super+Shift ${str x}";
                      value = "set-view-tags ${str (pow x)}";
                    })
                    9)
                ]
              )
          );
        Display = {
          "None Escape" = "enter-mode normal";
          # Move
          "Super H" = "move left  100";
          "Super J" = "move down  100";
          "Super K" = "move up    100";
          "Super L" = "move right 100";
          # Snap
          "Shift H" = "snap left";
          "Shift J" = "snap down";
          "Shift K" = "snap up";
          "Shift L" = "snap right";
          # Resize
          "Super+Shift  H" = "resize horizontal -100";
          "Super+Shift  J" = "resize vertical    100";
          "Super+Shift  K" = "resize vertical   -100";
          "Super+Shift  L" = "resize horizontal  100";
        };
      };
      spawn = ["rivertile"];
      default-layout = "rivertile";
    };
  };

  programs.eww = {
    enable = true;
    configDir = ./eww;
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

  services.ssh-agent.enable = true;

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentryPackage = pkgs.pinentry-tty;
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

    # delta = {
    #   enable = true;
    #   options = {
    #     navigate = true;
    #     light = false;
    #     syntax-theme = "gruvbox-dark";
    #     line-numbers = true;
    #   };
    # };

    signing = {
      key = "B9192CEACB44520B";
      signByDefault = true;
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
    icons = true;
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
    theme = "Everforest Dark Medium";
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
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "Gruvbox Dark";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
