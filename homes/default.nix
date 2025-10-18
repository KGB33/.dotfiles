{
  config,
  pkgs,
  lib,
  inputs,
  dagger',
  hmm',
  ...
}: {
  imports = [
    ../wezterm/wezterm.nix
    ../nushell/nushell.nix
    ../scripts/scripts.nix
    ../stylix.nix
    ../apps
    ./darwin.nix
    ./linux.nix
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
      "1password-cli"
      "claude-code"
      "crush"
      "discord"
      "obsidian"
      "steam-unwrapped"
    ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      alejandra # Nix formatter
      cabal-install
      cargo
      clipse
      claude-code
      crush
      docker-client
      doggo
      fd
      firefox
      fnlfmt
      fzf
      gh
      ghc
      gnused
      go
      goose-cli
      jq
      jqp
      lazydocker
      lazyjournal
      lefthook
      nerd-fonts.fira-code
      nickel
      noto-fonts-color-emoji
      obsidian
      # posting
      python313
      rainfrog
      ripgrep
      serie
      uv
      wireguard-tools
      wireshark-qt
      yazi
      yq-go
      zig
    ]
    ++ [dagger'.dagger hmm'];

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

    # Open man pages in Neovim
    MANPAGER = "nvim -c 'Man!' -o -";
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = false;
      dates = "weekly";
      extraArgs = "--keep 5";
    };
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

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };

  programs.git = {
    enable = true;
    userEmail = lib.mkDefault "keltonbassingthwaite@gmail.com";
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
      diff."nodiff" = {
        command = "echo Diff Not Shown.";
      };
    };
  };
  xdg.configFile."git/attributes" = {
    text = ''
      *.lock diff=nodiff
      package-lock.json diff=nodiff
    '';
  };

  programs.btop = {
    enable = true;
    settings = {
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

  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = true;
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    # enable_audio_bell = "no";
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    settings = {
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

  programs.ranger = {
    enable = true;
  };
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
  };

  programs.lazygit = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
