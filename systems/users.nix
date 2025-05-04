{pkgs, ...}: {
  users.users.kgb33 = {
    isNormalUser = true;
    description = "Kelton";
    extraGroups = ["wheel" "docker" "video" "audio"];
    shell = pkgs.fish;
  };
}
