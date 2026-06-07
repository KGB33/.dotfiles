{ inputs, lib, ... }:
{
  flake-file.inputs = {
    # Opt into v2 beta
    blink-cmp = {
      url = "github:saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  apps.nvim.homeManager =
    { pkgs, ... }:
    let
      compileFennel =
        name: src:
        pkgs.runCommand name
          {
            fnlSrc = src;
          }
          ''
            ${pkgs.luaPackages.fennel}/bin/fennel --compile - <<< "$fnlSrc" > "$out"
          '';
      review-nvim = pkgs.vimUtils.buildVimPlugin {
        name = "review-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "georgeguimaraes";
          repo = "review.nvim";
          rev = "v1.9.1";
          hash = "sha256-/iP4ALu1oGamZe34FvP32qrzmg6wCsa5mmDaVUhIt0c=";
        };
        nvimSkipModules = [ "review.picker" ];
      };

    in
    {
      xdg.configFile."nvim/lua/options.lua".source = compileFennel "nvim-options" (
        builtins.readFile ./nvim/options.fnl
      );
      xdg.dataFile."fennel-ls/docsets/nvim.lua".source = pkgs.fetchurl {
        url = "https://git.sr.ht/~micampe/fennel-ls-nvim-docs/blob/main/nvim.lua";
        hash = "sha256-ef9lDSKhECCE+GWqqxRsv43AtzoGzU67CCMed3EoS4A=";
      };
      programs.neovim = {
        extraPackages = with pkgs; [
          clojure-lsp
          fennel-ls
          harper
          nixd
          rust-analyzer
        ];
        enable = true;
        defaultEditor = true;
        initLua =
          # lua
          ''
            	  require("options")
          '';
        plugins =
          let
            blink' = inputs.blink-cmp.packages."${pkgs.system}".blink-cmp;
            ts-grammars =
              pkgs.vimPlugins.nvim-treesitter-parsers
              |> lib.filterAttrs (name: value: lib.isDerivation value)
              |> lib.attrValues;
            ts-queries = map (p: p.associatedQuery) ts-grammars;
          in
          with pkgs.vimPlugins;
          [
            mini-icons
            nvim-web-devicons
            which-key-nvim

            conjure
            vim-sexp
            vim-sexp-mappings-for-regular-people

            review-nvim
            codediff-nvim
            nui-nvim
            {
              plugin = blink';
              type = "fennel";
              config = builtins.readFile ./nvim/plugins/blink.fnl;
            }
            {
              plugin = nvim-lspconfig;
              type = "fennel";
              config = builtins.readFile ./nvim/plugins/lsp.fnl;
            }
            {
              plugin = telescope-nvim;
              type = "fennel";
              config = builtins.readFile ./nvim/plugins/telescope.fnl;
            }
          ]
          ++ ts-queries
          ++ ts-grammars;
      };
    };
}
