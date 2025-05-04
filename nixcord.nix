{...}: {
  programs.nixcord = {
    enable = true;
    config = {
      plugins = {
        alwaysExpandRoles.enable = true;
        betterFolders.enable = true;
        clearURLs.enable = true;
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
