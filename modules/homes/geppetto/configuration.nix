{self, ...}: {
  flake.modules.homeManager.geppetto = {...}: {
    imports = with self.modules.homeManager; [base linux niri home-dev stylix nixcord vicinae noctalia];
    home = {
      username = "kgb33";
      homeDirectory = "/home/kgb33/";
    };
    home.stateVersion = "23.11";
  };
}
