Service = require("node-linux").Service

# Create a new service object
svc = new Service(
  name: "virtualmin-backup-dropbox"
  description: "Backup virtualmin server backup files to dropbox."
  script: require("path").join(__dirname, "index.js")
  env:
    name: "NODE_ENV"
    value: "production"
)

# Listen for the "install" event, which indicates the
# process is available as a service.
svc.on "install", ->
  console.log "\nInstallation Complete\n---------------------"


#svc.start();

# Just in case this file is run twice.
svc.on "alreadyinstalled", ->
  console.log "This service is already installed."
  console.log "Attempting to start it."
  svc.start()


# Listen for the "start" event and let us know when the
# process has actually started working.
svc.on "start", ->
  console.log svc.name + " started!\nVisit http://127.0.0.1:3000 to see it in action.\n"


# Install the script as a service.
svc.install()