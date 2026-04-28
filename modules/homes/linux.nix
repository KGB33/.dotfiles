{...}: {
  flake.modules.homeManager.linux = {...}: {
    imports = [../../homes/linux.nix];
  };
}
