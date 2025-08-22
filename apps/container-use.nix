{pkgs, ...}: let
  container-use = pkgs.buildGoModule {
    pname = "container-use";
    version = "0.4.2";
    subPackages = ["cmd/container-use"];
    nativeCheckInputs = [pkgs.git];
    doCheck = false; # Checks hung for 4+mins
    src = pkgs.fetchFromGitHub {
      owner = "dagger";
      repo = "container-use";
      rev = "main";
      sha256 = "sha256-YKgS142a9SL1ZEjS+VArxwUzQX961zwlGuHW43AMxQA=";
    };
    vendorHash = "sha256-M7YhEm9Gmjv2gxB2r7AS5JLLThEkvtJfLBrB+cvsN5c=";
  };
in {
  home.packages = [container-use];
}
