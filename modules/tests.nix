# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      lib,
      ...
    }:
    let
      checkCond = name: cond: pkgs.runCommandLocal name { } (if cond then "touch $out" else "");
      geppetto = inputs.self.nixosConfigurations.geppetto.config;
      kgb33-at-geppetto = geppetto.home-manager.users.kgb33;
      vmBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists (self'.packages.vm + "/bin/vm");
      geppettoBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists (geppetto.system.build.toplevel);
    in
    {
      checks."geppetto builds" = checkCond "geppetto-builds" geppettoBuilds;
      checks."vm builds" = checkCond "vm-builds" vmBuilds;

      checks."kgb33 enabled geppetto nh" =
        checkCond "kgb33.provides.geppetto" geppetto.programs.nh.enable;
      # checks."geppetto enabled kgb33 neovim" =
      #   checkCond "geppetto.provides.kgb33" kgb33-at-geppetto.programs.neovim.enable;
      checks."geppetto enabled kgb33 git" =
        checkCond "geppetto.provides.kgb33" kgb33-at-geppetto.programs.git.enable;
    };
}
