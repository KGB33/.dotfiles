{ ... }:
{
  apps.taskwarrior.homeManager =
    { ... }:
    {
      programs.taskwarrior = {
        enable = true;
      };
    };
}
