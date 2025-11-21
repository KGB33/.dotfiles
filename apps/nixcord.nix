{
  lib,
  config,
  ...
}: {
  options.apps.nixcord.enable = lib.mkEnableOption "nixcord";

  config = lib.mkIf config.apps.nixcord.enable {
    programs.nixcord = {
      enable = true;
      discord = {
        vencord.enable = false;
        equicord.enable = true;
      };
      config = {
        plugins = {
          alwaysExpandRoles.enable = true;
          betterFolders.enable = true;
          clearUrLs.enable = true;
          callTimer.enable = true;
          mentionAvatars.enable = true;
          messageLogger.enable = true;
          moreUserTags.enable = true;
          noReplyMention.enable = true;
          replyTimestamp.enable = true;
        };
      };
    };
  };
}
