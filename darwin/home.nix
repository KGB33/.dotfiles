{pkgs, mac-app-util, ...}: {
  imports = [
        mac-app-util.homeManagerModules.default
  ];

  home.username = "keltonbassingthwaite";
  home.homeDirectory = "/Users/keltonbassingthwaite";

  home.packages = with pkgs; [
  ];
  
}
