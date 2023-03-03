This is a small stand alone tool to download
documents from grist for periodically backup purpose.

Change the config.ini accordingly:

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
# Wildcards are supported!
#  `*` Fetches all tables as csv
#  `MyTable*` Fetches all tables that start with "MyTable"
#  `*Expanses*` Fetches all tables that contain the word `Expanses` in the name
; Table1
; Table2
*
```

then run the downloadGrist executable.
The downloaded files will have a timestamp,
so its safe to run the tool over and over again.


Changelog
---------
UPCOMING
---
- v?.?.?


DONE
----
- v0.3.2
  - Added wildcard downloads to csv this means that for example::
    - `*` Fetches all tables as csv
    - `MyTable*` Fetches all tables that start with "MyTable"
    - `*Expanses*` Fetches all tables that contain the word `Expanses` in the name
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