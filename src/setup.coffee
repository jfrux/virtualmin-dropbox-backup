fs = require("fs")
util = require("util")
dbox = require("dbox")
yaml = require("js-yaml")
stdin = process.openStdin()

process.env.NODE_ENV = process.env.NODE_ENV || "development"
defaultConfig = 
  source_dir: "./backups/"
  destination_dir: "./backups/"
  app_key: "0000000"
  app_secret: "000000000000"
  access_token: null
  cron_schedule: "0 45 0 1/1 * ? *"

devConfigPath = "./config/development.yml"
prodConfigPath = "./config/production.yml"

configPath = "./config/#{process.env.NODE_ENV}.yml"

try
  config = require(configPath)
catch e
  console.log "Creating default config files..."
  fs.writeFileSync(devConfigPath,yaml.safeDump(defaultConfig))
  fs.writeFileSync(prodConfigPath,yaml.safeDump(defaultConfig))
  console.log "Done creating default configs."
  console.log "Please edit the ./config/#{process.env.NODE_ENV}.yml file with your APP_KEY and APP_SECRET from http://dropbox.com/developers."
  process.exit()

app = dbox.app(
  app_key: config.app_key
  app_secret: config.app_secret
)
app.requesttoken (status, request_token) ->
  unless status is 200
    console.error "ERROR: Did you put the app key and secret in ./config/#{process.env.NODE_ENV}.yml?"  
    process.exit()

  util.puts "Open the following URL in your browser and authorize the app:\n"
  util.puts request_token.authorize_url
  util.puts "\nPress return when it's done."
  stdin.once "data", ->
    app.accesstoken request_token, (status, access_token) ->
      unless status is 200
        console.log access_token
      else
        config.access_token = access_token
        fs.writeFileSync configPath, yaml.safeDump(config), "utf-8"
        console.log "Access token set up successfuly"
      process.exit()


