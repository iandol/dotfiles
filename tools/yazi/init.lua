require("starship"):setup()

-- Minimal reliable setup
require("sshfs"):setup({
  sshfs_options = {
    "reconnect",
    "ServerAliveInterval=15",
    "ServerAliveCountMax=3",
  },
})
