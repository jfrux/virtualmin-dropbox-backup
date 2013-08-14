fs = require "fs"
util = require "util"
dbox = require "dbox"
child_process = require "child_process"
dateFormat = require "dateformat"
yaml = require "js-yaml"
config = require "../config"
mkdirp = require("mkdirp").sync
_ = require "underscore"
schedule = require "node-schedule"
path = require "path"
async = require "async"

exec = child_process.exec

class Backup
  client: null
  files: []
  constructor: ->
    datedFolder = dateFormat(new Date(), "yyyy-mm-dd")
    @sourceDir = path.join config.source_dir,datedFolder
    @destDir = path.join config.destination_dir,datedFolder
    mkdirp @sourceDir
    mkdirp @destDir
    app = dbox.app(
      app_key: config.app_key
      app_secret: config.app_secret
    )
    @client = app.client(config.access_token)
    
    _.bindAll(@,"initDropbox","loadFiles","uploadFiles","upload")
    #startup
    async.series [
      @initDropbox
      @loadFiles
      @uploadFiles
    ]
    ,(err) ->
      throw err if err?
  initDropbox:(next) ->
    @client.account (status, reply) ->
      return next(new Error("Dropbox is not connected...")) unless status is 200
      console.log "Welcome, #{reply.display_name}!"
      next(null)
  loadFiles:(next) ->
    self = @
    fs.readdir @sourceDir, (err, files) ->
      return next(new Error(err)) if err?
      self.files = files
      next(null)
  uploadFiles:(next) ->
    self = @
    setupDir = (callback) ->
      cb = callback
      self.client.metadata self.destDir,(status,reply) ->
        if !reply.is_dir
          self.client.mkdir self.destDir, (status, reply) ->
            cb(null)
        else
          cb(null)

    doUpload = (callback) ->
      cb = callback
      console.log "Starting upload..."
      console.log self.files
      async.eachLimit self.files,3,self.upload,(err) ->
        throw cb(new Error(err)) if err?
        console.log "Done uploading all files."
        cb(null)

    async.series [
      setupDir
      doUpload
    ]
    ,(err) ->
      throw err if err?
      next(null)
  # compress: ->
  #   file = @files[@index]
  #   exec "tar -zcpvf " + config.local_backup_dir + "/" + file + ".tar.gz " + config.dir + "/" + file, (err, stdout, stderr) ->
  #     if err
  #       util.error "Error creating " + config.local_backup_dir + "/" + file + ".tar.gz"
  #       util.puts stdout
  #       util.puts stderr
  #       @next_file()
  #       return
  #     util.puts "Created local " + config.local_backup_dir + "/" + file + ".tar.gz"
  #     @upload()

  upload:(file,next) ->
    self = @
    sourceFile = path.join @sourceDir,file
    destFile = path.join @destDir,file
    
    fs.readFile sourceFile, (err, data) ->
      if err
        util.error "Error reading " + file
        next(null)
        return
      util.puts "Starting upload of " + file
      self.client.put destFile, data, (status, reply) ->
        util.puts "Upload of " + destFile + " completed (status: " + status + ")"
        next(null)
        # fs.unlink path, (err) ->
        #   util.puts "Deleting local backup: " + path + ": " + ((if err then "error" else "ok"))
        #   #@next_file()

doBackup = () ->
  backup = new Backup()
  console.log "Running..."

schedule.scheduleJob(config.cron_schedule, doBackup)
console.log "Virtualmin-Backup-Dropbox\nStatus: Idle..."