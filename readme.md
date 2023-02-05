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

then run the downloadGrist executable.
The downloaded files will have a timestamp,
so its safe to run the tool over and over again.


Changelog
---------

- v0.2.0 custom file name formatting.
- v0.1.0 Init