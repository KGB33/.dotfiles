{inputs, ...}: {
  flake-file.inputs.nixcord.url = "github:kaylorben/nixcord";

  flake.modules.homeManager.nixcord = {...}: {
    imports = [inputs.nixcord.homeModules.nixcord];

    programs.discord.enable = true;
    programs.nixcord = {
      enable = false;
      discord = {
        vencord.enable = false;
        equicord.enable = true;
      };
      config.plugins = {
        alwaysExpandRoles.enable = true;
        betterFolders.enable = true;
        ClearURLs.enable = true;
        callTimer.enable = true;
        mentionAvatars.enable = true;
        messageLogger.enable = true;
        moreUserTags.enable = true;
        noReplyMention.enable = true;
        replyTimestamp.enable = true;
      };
    };
  };
}
