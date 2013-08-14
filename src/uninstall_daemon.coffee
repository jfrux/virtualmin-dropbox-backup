Service = require("node-linux").Service

# Create a new service object
svc = new Service(
  name: "virtualmin-backup-dropbox"
  script: require("path").join(__dirname, "index.js")
)

# Listen for the "uninstall" event so we know when it's done.
svc.on "uninstall", ->
  console.log "Uninstall complete."
  console.log "The service exists: ", svc.exists

svc.on "error", (err) ->
  console.log "ERROR:", err


# Uninstall the service.
svc.uninstall()