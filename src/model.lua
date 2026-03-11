local _platformPlugin, _err = am.plugin.get("platform")
if not _platformPlugin then
    log_error("Cannot determine platform!", _err)
    return
end
local _ok, _platform = _platformPlugin.get_platform()
if not _ok then
    log_error("Cannot determine platform!")
    return
end

local _sourcesContent, _sourcesErr = fs.read_file("__mvrk/sources.hjson")
ami_assert(_sourcesContent, "Failed to read sources.hjson - " .. tostring(_sourcesErr))
local _downloadLinks = hjson.parse(_sourcesContent)

local _downlaodUrls = nil

if _platform.OS == "unix" then
    if _platform.DISTRO == "MacOS" then
        _downlaodUrls = _downloadLinks["darwin-arm64"]
    else
        _downlaodUrls = _downloadLinks["linux-x86_64"]
        if _platform.SYSTEM_TYPE:match("[Aa]arch64") then
            _downlaodUrls = _downloadLinks["linux-arm64"]
        end
    end
end

if _downlaodUrls == nil then
    log_warn("No download URLs found for platform: " .. tostring(_platform.OS) .. "/" .. tostring(_platform.DISTRO) .. "/" .. tostring(_platform.SYSTEM_TYPE))
end

am.app.set_model(
    {
        SYSTEM_OS = _platform.OS,
        SYSTEM_DISTRO = _platform.DISTRO,
        SYSTEM_TYPE = _platform.SYSTEM_TYPE,
        DOWNLOAD_URLS = am.app.get_configuration("SOURCES", _downlaodUrls),
    },
    { merge = true, overwrite = true }
)

local _services = require("__mvrk.services")
local _wantedBinaries = _services.allBinaries

---@type string[]
local _configuredAdditionalKeys = am.app.get_configuration("additional_key_aliases", {})
if not util.is_array(_configuredAdditionalKeys) then
    _configuredAdditionalKeys = {}
    log_warn("invalid additional_key_aliases configuration (skipped)")
end
---@type string[]
local _configuredKeys = am.app.get_configuration("key_aliases", { "baker" })
local _keys = "baker"
if util.is_array(_configuredAdditionalKeys) then
    _keys = string.join(" ", table.unpack(util.merge_arrays(_configuredKeys, _configuredAdditionalKeys)))
else
    log_warn("invalid keys configuration (skipped)")
end
local MAVRYK_LOG_LEVEL = am.app.get_configuration("MAVRYK_LOG_LEVEL", "info")

am.app.set_model(
    {
        WANTED_BINARIES = _wantedBinaries,
        RPC_ADDR = am.app.get_configuration("RPC_ADDR", "127.0.0.1"),
        REMOTE_SIGNER_ADDR = am.app.get_configuration("REMOTE_SIGNER_ADDR", "http://127.0.0.1:20090/"),
		SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and am.app.get_configuration("SERVICE_CONFIGURATION") or {},
            true
        ),
        BAKER_LOG_LEVEL = am.app.get_configuration("BAKER_LOG_LEVEL", MAVRYK_LOG_LEVEL),
        NODE_LOG_LEVEL = am.app.get_configuration("NODE_LOG_LEVEL", MAVRYK_LOG_LEVEL),
        VDF_LOG_LEVEL = am.app.get_configuration("VDF_LOG_LEVEL", MAVRYK_LOG_LEVEL),
        ACCUSER_LOG_LEVEL = am.app.get_configuration("ACCUSER_LOG_LEVEL", MAVRYK_LOG_LEVEL),
        KEY_ALIASES = _keys
    },
    { merge = true, overwrite = true }
)
