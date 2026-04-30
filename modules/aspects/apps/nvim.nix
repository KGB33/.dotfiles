{
  apps.nvim.homeManager = {pkgs, ...}: {
    programs.neovim = {
      enable = true;
    };
  };
}
