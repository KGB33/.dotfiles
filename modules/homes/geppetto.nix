{
  inputs,
  self,
  ...
}: {
  flake.homeConfigurations."kgb33" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
    modules = with self.modules.homeManager; [geppetto];
  };
}
