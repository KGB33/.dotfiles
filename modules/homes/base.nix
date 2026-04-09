{...}: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.base = {
    lib,
    pkgs,
    config,
    ...
  }: {
    # TODO: Change these imports to dendritic pattern.
    imports = [
      ../../scripts/scripts.nix
      ../../apps
      # ../../homes/darwin.nix
      ../../homes/linux.nix
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password-cli"
        "claude-code"
        "discord"
        "obsidian"
        "steam-unwrapped"
      ];

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
      alejandra # Nix formatter
      baobab
      cabal-install
      cargo
      claude-code
      docker-client
      doggo
      fd
      fnlfmt
      fzf
      gh
      ghc
      gnused
      go
      jq
      jqp
      lazydocker
      lazyjournal
      lefthook
      nerd-fonts.fira-code
      nickel
      nodejs_24
      noto-fonts-color-emoji
      obsidian
      python313
      rainfrog
      ripgrep
      serie
      uv
      wireguard-tools
      yaak
      yazi
      yq-go
      zig
    ];
    # ++ [dagger'.dagger hmm'];

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
  };
}
