{
  inputs,
  lib,
  ...
}: {
  config.flake.lib = {
    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.nixos.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };

    mkHome = system: name: {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        modules = [inputs.self.modules.home.${name}];
      };
    };
  };
}
