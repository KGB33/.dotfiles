{
  lib,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    acceleration = lib.mkIf pkgs.stdenv.isLinux "rocm";
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768";
      OLLAMA_FLASH_ATTENTION = "true";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
    };
  };
}
