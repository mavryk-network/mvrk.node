local service_manager = require "__mvrk.service-manager"
local services = require "__mvrk.services"
service_manager.remove_services(services.cleanup_names)

log_success("Node services succesfully removed.")
