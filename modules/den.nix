{ lib, ... }:
{
  den.hosts.x86_64-linux.geppetto.users.kgb33 = { };
  den.homes.x86_64-linux.kgb33 = { };
  den.homes.aarch64-darwin.keltonbassingthwaite = { };

  # enable hm for all users
  # Note: This appears to include HM in the nixos system build,
  # not just making it avalable for all users.
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
