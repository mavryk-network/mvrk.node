local _appId = am.app.get("id")

local _possibleResidue = {
	_appId .. "-mvrk-accuser-next",
	_appId .. "-mvrk-baker-next",
	_appId .. "-mvrk-endorser",
	_appId .. "-mvrk-endorser-next",
	_appId .. "-mvrk-vdf-next"
}

local _nodeServices = {
	[_appId .. "-mvrk-node"] = am.app.get_configuration("NODE_SERVICE_FILE", "__mvrk/assets/node")
}
local _vdfServices = {
	[ _appId .. "-mvrk-vdf"] = am.app.get_configuration("NODE_SERVICE_FILE", "__mvrk/assets/vdf"),
}
local _bakerServices = {
	[_appId .. "-mvrk-accuser"] = am.app.get_configuration("ACCUSER_SERVICE_FILE", "__mvrk/assets/accuser"),
	[_appId .. "-mvrk-baker"] = am.app.get_configuration("BAKER_SERVICE_FILE", "__mvrk/assets/baker"),
}

local _nodeBinaries = { "client", "node" }
local _bakerBinaries = { "accuser", "baker" }
local _vdfBinaries = { "baker" }

if am.app.get_model({ "DOWNLOAD_URLS", "baker-next" }, false) then
	_vdfServices[ _appId .. "mvrk-vdf-next"] = am.app.get_configuration("NODE_SERVICE_FILE", "__mvrk/assets/vdf")
	_bakerServices[_appId .. "-mvrk-baker-next"] = am.app.get_configuration("BAKER_NEXT_SERVICE_FILE", "__mvrk/assets/baker-next")
	table.insert(_bakerBinaries, "baker-next")
	table.insert(_vdfBinaries, "baker-next")
end
if am.app.get_model({ "DOWNLOAD_URLS", "accuser-next" }, false) then
	_bakerServices[_appId .. "-mvrk-accuser-next"] = am.app.get_configuration("ACCUSER_NEXT_SERVICE_FILE", "__mvrk/assets/accuser-next")
	table.insert(_bakerBinaries, "accuser-next")
end

local _nodeServiceNames = {}
for k, _ in pairs(_nodeServices) do
	_nodeServiceNames[k:sub((#(_appId .. "-mvrk-") + 1))] = k
end
local _bakerServiceNames = {}
for k, _ in pairs(_bakerServices) do
	_bakerServiceNames[k:sub((#(_appId .. "-mvrk-") + 1))] = k
end
local _vdfServiceNames = {}
for k, _ in pairs(_vdfServices) do
	_vdfServiceNames[k:sub((#(_appId .. "-mvrk-") + 1))] = k
end

local _activeServices = util.clone(_nodeServices)
local _activeNames = util.clone(_nodeServiceNames)
local _allBinaries = util.clone(_nodeBinaries)

local _isBaker = am.app.get_configuration("NODE_TYPE") == "baker"
if _isBaker then
	for k, v in pairs(_bakerServiceNames) do
		_activeNames[k] = v
	end
	for k, v in pairs(_bakerServices) do
		_activeServices[k] = v
	end
	for _, v in ipairs(_bakerBinaries) do
		if am.app.get_model({ "DOWNLOAD_URLS", v }, false) then
			table.insert(_allBinaries, v)
		end
	end
end

local _isVdf = am.app.get_configuration("NODE_TYPE") == "vdf"
if _isVdf then
	for k, v in pairs(_vdfServiceNames) do
		_activeNames[k] = v
	end
	for k, v in pairs(_vdfServices) do
		_activeServices[k] = v
	end
	for _, v in ipairs(_vdfBinaries) do
		if am.app.get_model({ "DOWNLOAD_URLS", v }, false) then
			table.insert(_allBinaries, v)
		end
	end
end

---@type string[]
local _cleanupNames = {}
_cleanupNames = util.merge_arrays(_cleanupNames, table.values(_nodeServiceNames))
_cleanupNames = util.merge_arrays(_cleanupNames, table.values(_bakerServiceNames))
_cleanupNames = util.merge_arrays(_cleanupNames, table.values(_vdfServiceNames))
_cleanupNames = util.merge_arrays(_cleanupNames, _possibleResidue)

return {
	active = _activeServices,
	active_names = _activeNames,
	allBinaries = _allBinaries,
	cleanup_names = _cleanupNames,
}