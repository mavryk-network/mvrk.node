local _args = table.pack(...)

local _user = am.app.get("user")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

if table.includes(_args, "--help") then
	print("Usage: ... bootstrap <url> [block hash] [--no-check]")
	return
end

local noCheck = false
if table.includes(_args, "--no-check") then
	_args = table.filter(_args, function(k, v) return v ~= "--no-check" and k ~= "n" end)
	noCheck = true
end

ami_assert(#_args >= 1, [[Please provide URL to snapshot source and block hash to import.
ami ... bootstrap <url> [block hash]])

-- check if node is running
local serviceManager = require"__mvrk.service-manager"
local services = require"__mvrk.services"
for k, v in pairs(services.active_names) do
	if type(v) ~= "string" then goto CONTINUE end
	local _, status, _ = serviceManager.safe_get_service_status(v)
	ami_assert(status ~= "running", "Some of node services is running, please stop them first...")
	::CONTINUE::
end

log_info"Preparing the snapshot import"
-- cleanup directory
local nodeDir = "./data/.mavryk-node"
local tmpNodeDir = "./data/.mavryk-node-tmp"
if not fs.exists(tmpNodeDir) and fs.exists(nodeDir) then
	os.rename(nodeDir, tmpNodeDir)
	fs.mkdirp(nodeDir)
	fs.copy_file(path.combine(tmpNodeDir, "config.json"), path.combine(nodeDir, "config.json"))
	fs.copy_file(path.combine(tmpNodeDir, "identity.json"), path.combine(nodeDir, "identity.json"))
end
-- make sure we have all required directories in place
fs.mkdirp(tmpNodeDir)
fs.mkdirp(nodeDir)

local toRemovePaths = {
	"context",
	"daily_logs",
	"lock",
	"store",
	-- we want to preserve + proofs
	-- "identity.json",
	-- "config.json",
	-- "peers.json",
	-- "version.json",
}
local nodeDirContent = fs.read_dir(tmpNodeDir, { return_full_paths = false, recurse = false })
local pathsToKeep = table.filter(nodeDirContent, function (_, v)
	return not table.includes(toRemovePaths, v)
end)

-- bootstrap
local _tmpFile = os.tmpname()
local _exists = fs.exists(_args[1])
if _exists then
	_tmpFile = _args[1]
else
	log_info("Downloading " .. tostring(_args[1]) .. "...")
	local _ok, _error = net.download_file(_args[1], _tmpFile, {follow_redirects = true, content_type = "binary/octet-stream", progress_function = (function ()
		local _lastWritten = 0
		return function(total, current) 
			local _progress = math.floor(current / total * 100)
			if math.fmod(_progress, 10) == 0 and _lastWritten ~= _progress then 
				_lastWritten = _progress
				io.write(_progress .. "%...")
				io.flush()
				if _progress == 100 then print() end
			end
		end
	end)()})
	if not _ok then
		fs.remove(_tmpFile)
		ami_error("Failed to download: " .. tostring(_error))
	end
end

local importArgs = { "snapshot", "import", _tmpFile }
if noCheck then
	table.insert(importArgs, "--no-check")
end
if #_args > 1 then
	table.insert(importArgs, "--block")
	table.insert(importArgs, _args[2])
end
local _proc = proc.spawn("./bin/node", importArgs, {
	stdio = "inherit",
	wait = true,
	env = { HOME = path.combine(os.cwd() --[[@as string]], "data") }
})
os.remove(_tmpFile)
ami_assert(_proc.exit_code == 0, "Failed to import snapshot!")

log_info"finishing the snapshot import"
for _, v in ipairs(pathsToKeep) do
	os.rename(path.combine(tmpNodeDir, v --[[@as string]]), path.combine(nodeDir, v --[[@as string]]))
end
fs.remove(tmpNodeDir, { recurse = true })

local _uid, _err = fs.getuid(_user)
ami_assert(_uid, "Failed to get " .. _user .. "uid - " .. tostring(_err))
local _ok, _error = fs.chown("data", _uid, _uid, { recurse = true, recurse_ignore_errors = true })
if not _ok then
	ami_error("Failed to chown data - " .. tostring(_error))
end

log_success("Snapshot imported.")
