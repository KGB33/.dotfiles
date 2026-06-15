{ ... }:
{
  apps.lemurs.nixos =
    { ... }:
    {
      services.displayManager.lemurs.enable = true;
    };
}
