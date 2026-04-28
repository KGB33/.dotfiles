{
  inputs,
  self,
  ...
}: {
  # flake.homeConfigurations."keltonbassingthwaite" = inputs.home-manager.lib.homeManagerConfiguration {
  #   pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
  #   modules = with self.modules.homeManager; [kelton-mbp];
  # };
}
