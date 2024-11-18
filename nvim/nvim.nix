{pkgs, ...}: {
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      fzf
      typescript

      # Lsp
      csharp-ls
      elixir-ls
      gopls
      harper
      haskell-language-server
      lua-language-server
      ltex-ls
      markdown-oxide
      marksman
      nixd
      phpactor
      pyright
      ruff
      rust-analyzer
      typescript-language-server
      zls

      # DAP
      netcoredbg # C#
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
          p.tree-sitter-c-sharp
          p.tree-sitter-dockerfile
          p.tree-sitter-json
          p.tree-sitter-gleam
          p.tree-sitter-lua
          p.tree-sitter-hcl
          p.tree-sitter-markdown
          p.tree-sitter-markdown-inline
          p.tree-sitter-nix
          p.tree-sitter-nu
          p.tree-sitter-python
          p.tree-sitter-haskell
          p.tree-sitter-php
          p.tree-sitter-rust
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
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      vim.treesitter.language.add("nu", {
          path = "${pkgs.tree-sitter-grammars.tree-sitter-nu}/parser"
      })
    '';
  };
}
