{self, ...}: {
  flake.modules.homeManager.home-dev = {...}: {
    imports = with self.modules.homeManager; [git jujutsu nvim tmux television];
  };
}
