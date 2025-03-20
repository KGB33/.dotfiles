{pkgs, ...}: {
  home.file.tsQueries = {
    enable = true;
    recursive = true;
    source = ./ts_queries;
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
      harper
      haskell-language-server
      lua-language-server
      ltex-ls
      markdown-oxide
      marksman
      nixd
      ocamlPackages.ocaml-lsp
      postgres-lsp
      phpactor
      pyright
      ruff
      rust-analyzer
      typescript-language-server
      zls

      # Formatters
      ocamlformat

      # DAP
    ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        config = builtins.readFile ./plugins/lspconfig.lua;
        type = "lua";
      }

      # nvim-cmp sources
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      {
        plugin = nvim-cmp;
        config = builtins.readFile ./plugins/cmp.lua;
        type = "lua";
      }
      {
        plugin = nvim-treesitter.withPlugins (p: [
          p.tree-sitter-bash
          p.tree-sitter-css
          p.tree-sitter-dockerfile
          p.tree-sitter-fish
          p.tree-sitter-gleam
          p.tree-sitter-graphql
          p.tree-sitter-haskell
          p.tree-sitter-hcl
          p.tree-sitter-hjson
          p.tree-sitter-html
          p.tree-sitter-json
          p.tree-sitter-json5
          p.tree-sitter-just
          p.tree-sitter-lua
          p.tree-sitter-markdown
          p.tree-sitter-markdown-inline
          p.tree-sitter-nix
          p.tree-sitter-nu
          p.tree-sitter-ocaml
          p.tree-sitter-php
          p.tree-sitter-python
          p.tree-sitter-rust
          p.tree-sitter-scss
          p.tree-sitter-sql
          p.tree-sitter-toml
          p.tree-sitter-typescript
          p.tree-sitter-vim
          p.tree-sitter-yaml
          p.tree-sitter-yuck
          p.tree-sitter-zig
        ]);
        config = builtins.readFile ./plugins/treesitter.lua;
        type = "lua";
      }
      nvim-treesitter-parsers.angular
      nvim-treesitter-parsers.yuck
      {
        plugin = everforest;
        config = builtins.readFile ./plugins/everforest.lua;
        type = "lua";
      }
      nvim-treesitter-parsers.vimdoc
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/telescope.lua;
      }
      telescope-ui-select-nvim

      # DAP
      {
        plugin = nvim-dap;
        config = builtins.readFile ./plugins/dap.lua;
        type = "lua";
      }
      telescope-dap-nvim
      nvim-dap-ui
      nvim-nio

      which-key-nvim
      {
        plugin = flash-nvim;
        config = builtins.readFile ./plugins/flash.lua;
        type = "lua";
      }
      {
        plugin = glance-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/glance.lua;
      }
      {
        plugin = avante-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/avante.lua;
      }
      img-clip-nvim
      {
        plugin = nvim-dbee;
        type = "lua";
        config = ''
          require("dbee").setup()
        '';
      }
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      vim.treesitter.language.add("nu", {
          path = "${pkgs.tree-sitter-grammars.tree-sitter-nu}/parser"
      })
    '';
  };
}
