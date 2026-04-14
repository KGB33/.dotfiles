{...}: {
  flake.modules.homeManager.nvim = {
    pkgs,
    lib,
    ...
  }: let
    compileFennelStr = name: src: let
      lua = builtins.readFile (pkgs.runCommand "${name}.lua" {inherit src;} ''
        echo "$src" | ${pkgs.luajitPackages.fennel}/bin/fennel --compile - > $out
      '');
    in ";(function()\n${lua}\nend)()";

    transpileFennelPlugins = map (
      p:
        if (p.type or null) == "fennel"
        then
          p
          // {
            type = "lua";
            config = compileFennelStr (lib.getName p.plugin) p.config;
          }
        else p
    );
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

      withNodeJs = false;
      withRuby = false;
      withPython3 = false;

      extraPackages = with pkgs; [
        fzf
        typescript

        # Lsp
        clojure-lsp
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
          config = builtins.readFile ./nvim/fnl/${fn}.fnl;
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
      in
        [
          nui-nvim
          codediff-nvim
          (mkFnlPlugin review-nvim "review")

          (mkFnlPlugin catppuccin-nvim "catppuccin")
          vim-sexp
          vim-sexp-mappings-for-regular-people
          vim-repeat
          vim-surround
          conjure

          vim-jack-in
          vim-dispatch

          {
            plugin = nvim-lspconfig;
            config = builtins.readFile ./nvim/plugins/lspconfig.lua;
            type = "lua";
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
        ]
        |> transpileFennelPlugins;

      initLua = ''
        ${compileFennelStr "options" (builtins.readFile ./nvim/fnl/options.fnl)}
        vim.treesitter.language.add("nu", {
            path = "${pkgs.tree-sitter-grammars.tree-sitter-nu}/parser"
        })
      '';
    };

    home.sessionVariables = {
      NVIM_FIREFOX_DEBUG_EXTENSION = "${pkgs.vscode-extensions.firefox-devtools.vscode-firefox-debug}";
    };
  };
}
