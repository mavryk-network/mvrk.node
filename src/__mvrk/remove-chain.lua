local _keep = {
	"config.json",
	"identity.json",
	"peers.json"
}

local _entries, _err = fs.read_dir("data/.mavryk-node", { return_full_paths = true })
ami_assert(_entries, "Failed to remove chain files - " .. tostring(_err))
for _, entry in ipairs(_entries or {}) do
	local _matched = false
	for _, keep in ipairs(_keep) do
		_matched = _matched or entry:match(keep.."$")
	end
	if not _matched then
		fs.remove(entry, { recurse = true, follow_links = true })
	end
end