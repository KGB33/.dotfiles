{pkgs, ...}: {
  programs.neovim = let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      fzf

      # Lsp
      csharp-ls
      elixir-ls
      gopls
      haskell-language-server
      lua-language-server
      ltex-ls
      markdown-oxide
      nixd
      phpactor
      pyright
      ruff
      rust-analyzer

      # DAP
      netcoredbg # C#
    ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./plugins/lspconfig.lua;
      }

      # nvim-cmp sources
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      {
        plugin = nvim-cmp;
        config = toLuaFile ./plugins/cmp.lua;
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
          p.tree-sitter-toml
          p.tree-sitter-vim
          p.tree-sitter-yaml
          p.tree-sitter-yuck
        ]);
        config = toLuaFile ./plugins/treesitter.lua;
      }
      nvim-treesitter-parsers.yuck
      {
        plugin = everforest;
        config = toLuaFile ./plugins/everforest.lua;
      }
      nvim-treesitter-parsers.vimdoc
      {
        plugin = telescope-nvim;
        config = toLuaFile ./plugins/telescope.lua;
      }

      # DAP
      {
        plugin = nvim-dap;
        config = toLuaFile ./plugins/dap.lua;
      }
      telescope-dap-nvim
      nvim-dap-ui
      nvim-nio
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      vim.treesitter.language.add("nu", {
          path = "${pkgs.tree-sitter-grammars.tree-sitter-nu}/parser"
      })
    '';
  };
}
