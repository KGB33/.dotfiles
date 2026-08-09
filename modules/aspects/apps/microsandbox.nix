{ ... }:
let
  version = "0.6.8";

  release = "https://github.com/superradcompany/microsandbox/releases/download/v${version}";
  bundles = {
    x86_64-linux = {
      asset = "microsandbox-linux-x86_64.tar.gz";
      hash = "sha256-mSvmbOimGWWzrHczvOWNapioKSoXLoXIdRB0oq0W9p0=";
      # `libkrunfw_filename()` in crates/utils.
      libkrunfw = "libkrunfw.so.5.6.1";
    };
    aarch64-darwin = {
      asset = "microsandbox-darwin-aarch64.tar.gz";
      hash = "sha256-+SrK7uH+/VJxmXvw5SJgDTK0o3J5bR4PAOIp+aj/CJA=";
      libkrunfw = "libkrunfw.5.dylib";
    };
  };

  # Apple Silicon is the only mac upstream builds for.
  supported = pkgs: bundles ? ${pkgs.stdenv.hostPlatform.system};

  msbFor =
    pkgs:
    let
      inherit (pkgs) lib;
      inherit (pkgs.stdenv.hostPlatform) isDarwin system;
      bundle = bundles.${system};
    in
    pkgs.stdenv.mkDerivation {
      pname = "microsandbox";
      inherit version;

      src = pkgs.fetchurl {
        url = "${release}/${bundle.asset}";
        inherit (bundle) hash;
      };

      sourceRoot = ".";

      nativeBuildInputs = lib.optionals (!isDarwin) [ pkgs.autoPatchelfHook ];
      buildInputs = lib.optionals (!isDarwin) [
        pkgs.libcap_ng
        pkgs.stdenv.cc.cc.lib
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 msb $out/bin/msb
        install -Dm755 ${bundle.libkrunfw} $out/lib/${bundle.libkrunfw}

        runHook postInstall
      '';

      # The darwin binaries arrive signed, touching them voids that.
      dontFixup = isDarwin;

      meta = {
        description = "Self-hosted microVM sandbox for running untrusted code";
        homepage = "https://github.com/superradcompany/microsandbox";
        license = lib.licenses.asl20;
        mainProgram = "msb";
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        platforms = builtins.attrNames bundles;
      };
    };
in
{
  apps.microsandbox.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optional (supported pkgs) (msbFor pkgs);
    };
}
