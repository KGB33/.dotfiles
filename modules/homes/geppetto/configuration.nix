{self, ...}: {
  flake.modules.homeManager.geppetto = {...}: {
    imports = with self.modules.homeManager; [home-dev];
    home = {
      username = "kgb33";
      homeDirectory = "/home/kgb33/";
    };
    home.stateVersion = "23.11";
  };
}
