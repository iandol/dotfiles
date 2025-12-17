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
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
