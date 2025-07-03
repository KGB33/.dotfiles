{
  lib,
  pkgs,
}: let
  version = "0.0.23x";
  src = pkgs.fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "935234981b01da1bbfc03de963eb5132e58fc805";
    hash = "sha256-FwB9zifsQlYz/cKQDlwftkKrs8djZokq6Ua6/lyujU8";
  };
  avante-nvim-lib = pkgs.rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    inherit version src;

    useFetchCargoVendor = true;
    cargoHash = "sha256-8mBpzndz34RrmhJYezd4hLrJyhVL4S4IHK3plaue1k8=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.makeWrapper
      pkgs.perl
    ];

    buildInputs = [
      pkgs.openssl
    ];

    buildFeatures = ["luajit"];

    checkFlags = [
      # Disabled because they access the network.
      "--skip=test_hf"
      "--skip=test_public_url"
      "--skip=test_roundtrip"
      "--skip=test_fetch_md"
    ];
  };
in
  pkgs.vimUtils.buildVimPlugin {
    pname = "avante.nvim";
    inherit version src;

    dependencies = with pkgs.vimPlugins; [
      dressing-nvim
      img-clip-nvim
      nui-nvim
      nvim-treesitter
      plenary-nvim
    ];

    postPatch = ''
      # Remove the specific debug lines
      find . -name "*.lua" -exec sed -i '/M\.debug.*lazy\.nvim is not available/d' {} \;
      find . -name "*.lua" -exec sed -i '/Utils\.debug.*Setting up avante colors/d' {} \;
    '';

    postInstall = let
      ext = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      mkdir -p $out/build
      ln -s ${avante-nvim-lib}/lib/libavante_repo_map${ext} $out/build/avante_repo_map${ext}
      ln -s ${avante-nvim-lib}/lib/libavante_templates${ext} $out/build/avante_templates${ext}
      ln -s ${avante-nvim-lib}/lib/libavante_tokenizers${ext} $out/build/avante_tokenizers${ext}
      ln -s ${avante-nvim-lib}/lib/libavante_html2md${ext} $out/build/avante_html2md${ext}
    '';

    nvimSkipModules = [
      # Requires setup with corresponding provider
      "avante.providers.azure"
      "avante.providers.copilot"
      "avante.providers.vertex_claude"
      "avante.providers.vertex"
      "avante.providers.ollama"
      "avante.providers.gemini"
    ];

    meta = {
      description = "Neovim plugin designed to emulate the behaviour of the Cursor AI IDE";
      homepage = "https://github.com/yetone/avante.nvim";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [
        KGB33
      ];
    };
  }
