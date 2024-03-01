{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kgb33";
  home.homeDirectory = "/home/kgb33";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  xdg = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    GNUPGHOME = "${config.xdg.configHome}/gnupg";

    # Docker
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";

    # Go
    GOPATH = "${config.xdg.dataHome}/go";

    # Rust
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";

    NIXOS_OZONE_WL = "1";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      exec-once = [
        "eww open top_bar"
      ];
      monitor = [
        "eDP-2,preferred,auto,1"
        ",preferred,auto,1,mirror,eDP-2"
      ];
      decoration = {
        rounding = 5;
      };
      "$mod" = "SUPER";
      bind =
        [
          "$mod, M, exit"
          "$mod, F, exec, firefox"
          "$mod, Q, exec, kitty"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList
            (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
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
    pinentryFlavor = "curses";
  };

  programs.git = {
    enable = true;
    userEmail = "keltonbassingthwaite@gmail.com";
    userName = "Kelton Bassingthwaite";

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        syntax-theme = "gruvbox-dark";
        line-numbers = true;
      };
    };

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

  programs.neovim =
    let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in
    {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = with pkgs; [
        fzf

        # Lsp
        elixir-ls
        gopls
        haskell-language-server
        lua-language-server
        nixd
        nodePackages.pyright
        rust-analyzer
      ];

      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./nvim/plugins/lspconfig.lua;
        }

        # nvim-cmp sources
        luasnip
        cmp_luasnip
        cmp-nvim-lsp
        cmp-path
        {
          plugin = nvim-cmp;
          config = toLuaFile ./nvim/plugins/cmp.lua;
        }
        {
          plugin = (nvim-treesitter.withPlugins (p: [
            p.tree-sitter-nix
            p.tree-sitter-vim
            p.tree-sitter-lua
            p.tree-sitter-python
            p.tree-sitter-json
            p.tree-sitter-yuck
          ]));
        }
        nvim-treesitter-parsers.yuck
        {
          plugin = everforest;
          config = toLuaFile ./nvim/plugins/everforest.lua;
        }
        {
          plugin = telescope-nvim;
          config = toLuaFile ./nvim/plugins/telescope.lua;
        }
      ];

      extraLuaConfig = ''
        ${builtins.readFile ./nvim/options.lua}
      '';
    };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "FiraCode";
      size = 10;
    };
    theme = "Everforest Dark Medium";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}