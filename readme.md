% downloadGrist(1)
% David Krause (enthus1ast) <krause@biochem2.uni-frankfurt.de>
% April 2023


# hAME

**downloadGrist** - a small stand alone tool to download
documents from grist for periodically backup purpose.

# SYNOPSIS

```
downloadGrist
```


# DESCRIPTION

**downloadGrist** can download grist documents in all available
formats:

- sqlite (.grist)
- xlsx
- csv

A timestamp is added to the files, so the tool can be run repeatedly,
to create snapshots of your grist documents.


# CONFIGURATION

(Since version 0.4.0) downloadGrist supports config dirs.
So there are three locations where the config is read from.

1. From the old file `config.ini` next to the executable (old 0.3 behavior)
2. From the old file `downloadGrist.ini` in the OS's config folder (appdata or .~/.config)
3. From all configs in the `downloadGrist/*.ini`  folder.

The configuration files are stored in the users
`.config/downloadGrist/` dir on linux.

And in `%APPDATA%\downloadGrist\` on windows.

One can create multiple config files, they must end with `.ini`

so for example:

- `Downloads/downloadGrist/config.ini"
- `.config/downloadGrist.ini` 
- `.config/downloadGrist/foo.ini`
- `.config/downloadGrist/baa.ini`

all of these config files are evaluated when **downloadGrist** runs.
 

Change or create the config files accordingly:

```ini
[common]
server = "https://docs.getgrist.com/"
docId = "myDocId"
apiKey = "myApiKey"
documentName = "myDocumentName"

# where the backups are stored.
# if `downloadDir` is a relative path, it will be relative
# to the `gristDownload` executable.
# Please note: a windows path must be written in triple quotes:
#  """C:\myBackupDir"""
downloadDir = backups

[downloads]
downloadXLSX = true
downloadSQLITE = true
downloadCSV = true

[format]
# The format for the filename
# Available placeholders:
# {{documentName}}
#   the name of the document that is downloaded
#
# {{dateStr}}
#   the date string when the download has started
#
# {{csvtable}}
#   the name of the csv table.
formatSQLITE = "{{documentName}}__{{dateStr}}.sqlite"
formatXLSX = "{{documentName}}__{{dateStr}}.xlsx"
formatCSV = "{{documentName}}-{{csvtable}}__{{dateStr}}.csv"

[csvtables]
# List all the tables you want to download as csv here.
# This section is ignored when you disable downloadCSV
Table1
Table2
```


then run the **downloadGrist** executable.

The downloaded files will have a timestamp,
so its safe to run the tool over and over again.


## Changelog


### UPCOMING

- v?.?.?
  - Experimental .deb package.


### DONE
- v0.4.0
  - Config dir instead of config file, to allow multiple
    configured downloads.
    default on linux (posix) is ~/.config/downloadGrist/*.ini
  - On linux (posix) log to syslog instead of logfile.
  - The config is in the users config dir now.
  - Display the name of the document in the logs
- v0.3.2
  - fix nimble zigcc package
  - fix nimble build -> renamed
- v0.3.1
  - Fixed bug that prevents v0.3.0 from running. (ApiKey always empty.)
  - Use platform specific newline character in generated config.
    - Older versions of Windows display the config config correct in notepad.
  - Print Version in the logs
  - Fixed bug that does not print csv tables in the log.
- v0.3.0
  - Added logging
  - Do not create files in case of an error.
  - create config.ini in case its missing
  - In case of an error the application quits with an return code of "1".
  - Added linux builds
    - amd64
    - arm
    - arm-linux-gnueabi
    - arm-linux-gnueabihf
- v0.2.1 added csvtable readme
- v0.2.0 custom file name formatting.
- v0.1.0 Init


# CODE 

The source is available on github: https://github.com/enthus1ast/nimDownloadGrist
