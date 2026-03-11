local service_manager = require "__mvrk.service-manager"
local services = require "__mvrk.services"
service_manager.start_services(services.active_names)
log_success("Node services succesfully started.")
