{...}: {
  flake.modules.homeManager.nvim = {
    pkgs,
    lib,
    config,
    ...
  }: let
    avanteOverride = import ./nvim/_avante.nix {
      pkgs = pkgs;
      lib = lib;
    };
  in {
    home.file.tsQueries = {
      enable = true;
      recursive = true;
      source = ./nvim/ts_queries;
      target = ".config/nvim/after/queries/";
    };

    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = with pkgs; [
        fzf
        typescript

        # Lsp
        elixir-ls
        gopls
        fennel-ls
        harper
        haskell-language-server
        lua-language-server
        ltex-ls
        markdown-oxide
        marksman
        nixd
        nls # Nickel LSP
        ocamlPackages.ocaml-lsp
        postgres-language-server
        phpactor
        pyright
        ruff
        rust-analyzer
        typescript-language-server
        zls

        # Formatters
        ocamlformat
        fnlfmt
      ];

      plugins = with pkgs.vimPlugins; let
        mkFnlPlugin = p: fn: {
          plugin = p;
          type = "fennel";
          runtime."fnl/${fn}Config.fnl".text = builtins.readFile ./nvim/fnl/${fn}.fnl;
        };
        review-nvim = pkgs.vimUtils.buildVimPlugin {
          name = "review-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "georgeguimaraes";
            repo = "review.nvim";
            rev = "v1.9.1";
            hash = "sha256-/iP4ALu1oGamZe34FvP32qrzmg6wCsa5mmDaVUhIt0c=";
          };
          nvimSkipModules = ["review.picker"];
        };
      in [
        nui-nvim
        codediff-nvim
        (mkFnlPlugin review-nvim "review")

        (mkFnlPlugin catppuccin-nvim "catppuccin")
        vim-sexp
        vim-sexp-mappings-for-regular-people
        vim-repeat
        vim-surround
        conjure
        {
          plugin = nvim-lspconfig;
          config = builtins.readFile ./nvim/plugins/lspconfig.lua;
          type = "lua";
        }
        {
          plugin = blink-cmp-avante;
        }
        {
          plugin = blink-cmp;
          config = builtins.readFile ./nvim/plugins/blink.lua;
          type = "lua";
        }
        (mkFnlPlugin nvim-treesitter.withAllGrammars "treesitter")
        (mkFnlPlugin telescope-nvim "telescope")
        telescope-ui-select-nvim

        # DAP
        (mkFnlPlugin nvim-dap "dap")
        telescope-dap-nvim
        nvim-dap-ui
        nvim-nio

        which-key-nvim
        (mkFnlPlugin flash-nvim "flash")
        {
          plugin = glance-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/glance.lua;
        }
        (mkFnlPlugin avanteOverride "avante")
        img-clip-nvim
        {
          plugin = nvim-dbee;
          type = "lua";
          config = ''
            require("dbee").setup()
          '';
        }
        {
          plugin = render-markdown-nvim;
          type = "lua";
          config = ''
            require('render-markdown').setup({
              completions = { blink = { enabled = true } },
            })
          '';
        }
        {
          plugin = hotpot-nvim;
          runtime."fnl/options.fnl".text = builtins.readFile ./nvim/fnl/options.fnl;
          config = let
            requireables =
              ["hotpot" "options"]
              ++ (config.programs.neovim.plugins
                |> builtins.filter (p: p.type == "fennel")
                |> builtins.concatMap (p: builtins.attrNames p.runtime)
                |> map (p':
                  p'
                  |> baseNameOf
                  |> lib.removeSuffix ".fnl"));
          in
            lib.concatStrings (map (name: "require(\"${name}\")\n") requireables);
          type = "lua";
        }
      ];

      initLua = ''
        vim.treesitter.language.add("nu", {
            path = "${pkgs.tree-sitter-grammars.tree-sitter-nu}/parser"
        })
      '';
    };

    home.sessionVariables = {
      NVIM_FIREFOX_DEBUG_EXTENSION = "${pkgs.vscode-extensions.firefox-devtools.vscode-firefox-debug}";
    };
    home.activation.hotpotSync = lib.hm.dag.entryAfter ["writeBoundary"] ''
      cd ~/.config/nvim && ${pkgs.neovim}/bin/nvim +"Hotpot sync force" +q
    '';
  };
}
