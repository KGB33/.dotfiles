{ ... }:
let
  unfreeMod =
    { lib, config, ... }:
    {
      options.den.unfree.predicates = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      config.nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.den.unfree.predicates;
    };
in
{
  den.aspects.unfree = {
    nixos = unfreeMod;
    homeManager = unfreeMod;
  };
}
