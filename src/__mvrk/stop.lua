local service_manager = require "__mvrk.service-manager"
local services = require "__mvrk.services"
log_info("Stopping node services... this may take a few minutes.")
service_manager.stop_services(services.active_names)
log_success("Node services succesfully stopped.")
