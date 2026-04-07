{...}: {
  flake.modules.homeManager.geppetto = {...}: {
    home = {
      username = "kgb33";
      homeDirectory = "/home/kgb33/";
    };
    home.stateVersion = "23.11";
  };
}
