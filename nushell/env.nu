$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent"
$env.config.hooks.command_not_found = {
    |cmd|
    print (nh search $cmd | str trim)
}
