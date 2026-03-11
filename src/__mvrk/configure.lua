local _ok, _error = fs.mkdirp("data")
ami_assert(_ok, "failed to create data directory: " .. tostring(_error))

log_info("Configuring " .. am.app.get("id") .. " services...")

local service_manager = require "__mvrk.service-manager"
local services = require "__mvrk.services"
service_manager.remove_services(services.cleanup_names) -- cleanup past install
service_manager.install_services(services.active)

log_success(am.app.get("id") .. " services configured")

log_info("Downloading zcash parameters... (This may take a few minutes.)")

local _download_zk_params = require"__mvrk.download-zk-params"
local _ok, _error = _download_zk_params()
ami_assert(_ok, "Failed to fetch params: " .. tostring(_error))

local _configFile = am.app.get_configuration("CONFIG_FILE")
if type(_configFile) == "table" and not table.is_array(_configFile) then
	log_info("Creating config file...")
	fs.mkdirp("./data/.mavryk-node/")
	fs.write_file("./data/.mavryk-node/config.json", hjson.stringify_to_json(_configFile))
elseif fs.exists("./__mvrk/node-config.json") then
	fs.mkdirp("./data/.mavryk-node/")
	fs.copy_file("./__mvrk/node-config.json", "./data/.mavryk-node/config.json")
end

-- vote file
local _voteFile = am.app.get_configuration("VOTE_FILE")
local _voteFileResult = {}
local _baselineFile, _err = fs.read_file("./__mvrk/assets/default-vote-file.json")
if _baselineFile then
	local _baseline, _err = hjson.parse(_baselineFile)
	if _baseline and type(_baseline) == "table" and not table.is_array(_baseline) then
		_voteFileResult = _baseline
	end
end
if type(_voteFile) == "table" and not table.is_array(_voteFile) then
	_voteFileResult = util.merge_tables(_voteFileResult, _voteFile, true)
elseif _voteFile then
	log_warn("Invalid 'VOTE_FILE' detected!")
end
fs.write_file("./data/vote-file.json", hjson.stringify_to_json(_voteFileResult))

-- finalize
require "__mvrk.base_utils".setup_file_ownership()