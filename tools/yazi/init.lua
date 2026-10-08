require("starship"):setup()

require("zoxide"):setup {
  update_db = true,
}

-- Minimal reliable setup
require("sshfs"):setup({
  sshfs_options = {
    "reconnect",
    "ServerAliveInterval=15",
    "ServerAliveCountMax=3",
  },
})

function Linemode:size_and_mtime()
	local time = self._file.cha.mtime
	if not time then
		time = ""
	elseif time.year == ya.time().year then
		time = time:format("%b %d %H:%M")
	else
		time = time:format("%b %d  %Y")
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

vf.sftp = {
  nas = {
    host = "10.10.47.188",
    user = "Ian",
    port = 2222,
    password = os.getenv("NAS_PWD"),
  },
}


