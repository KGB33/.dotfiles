{ inputs, ... }:
{
  flake-file.inputs.hmm = {
    url = "github:KGB33/hmm";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  apps.tmux.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = [
        inputs.hmm.packages."${pkgs.system}".hmm
      ];

      programs.tmux = {
        enable = true;
        escapeTime = 300;
        terminal = "tmux-256color";
        keyMode = "vi";
        extraConfig =
          # TODO: Make TV provide addtional config
          # '' bind t display-popup -E -w 85% -h 85% bash -c 'exec `tv tss`'''
          ''
            bind C-g display-popup -E -w 85% -h 85% "${pkgs.lazygit}/bin/lazygit"
          '';
      };
    };
}
