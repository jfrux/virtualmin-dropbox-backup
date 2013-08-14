virtualmin-dropbox-backup
=========================

a backup system written in node.js to upload virtualmin server backup's to your dropbox account.

### Usage
- Go to `https://www.dropbox.com/developers/apps` and register a new application.
- Download virtualmin-dropbox-backup via git: 
  `git clone https://github.com/joshuairl/virtualmin-dropbox-backup.git`
- Copy / paste the app_key and app_secret into the `./config/production.yml` and `./config/development.yml`.
- Run `NODE_ENV=development node setup`
- Copy the URL and paste into browser when prompted to authorize your app on your dropbox account.
- Go back to prompt and hit 'Enter'.
- If all went well, you should now be able to run `NODE_ENV=development node index`
  This causes the app to look in the ./backups/%Y-%m-%d folder for files, if it finds some... it will upload them to your Dropbox under `Apps/virtualmin/backups/%Y-%m-%d`
