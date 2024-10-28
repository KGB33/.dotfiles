{
  pkgs,
  mac-app-util,
  ...
}: {
  imports = [
    mac-app-util.homeManagerModules.default
    ../zsh/zsh.nix
  ];

  home.username = "keltonbassingthwaite";
  home.homeDirectory = "/Users/keltonbassingthwaite";

  home.packages = with pkgs; [
  ];

  programs.git.userEmail = "kelton@cdlpowersuite.com";
}
