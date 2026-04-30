# enables `nix run .#vm`. it is very useful to have a VM
# you can edit your config and launch the VM to test stuff
# instead of having to reboot each time.
{
  inputs,
  vm,
  ...
}: {
  den.aspects.geppetto = {
    includes = [
      # vm.base.provides.gui
      vm.base.provides.tui
    ];
    nixos.users.users.kgb33.initialPassword = "password";
  };

  perSystem = {pkgs, ...}: {
    packages.vm = pkgs.writeShellApplication {
      name = "vm";
      text = ''
        ${inputs.self.nixosConfigurations.geppetto.config.system.build.vm}/bin/run-geppetto-vm "$@"
      '';
    };
  };
}
