{lib, ...}: {
  den.hosts.x86_64-linux.geppetto.users.kgb33 = {};
  den.homes.x86_64-linux.kgb33 = {};

  # enable hm for all users
  den.schema.user.classes = lib.mkDefault ["homeManager"];
}
