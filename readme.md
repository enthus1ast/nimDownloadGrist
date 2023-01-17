This is a small stand alone tool to download
documents from grist for periodically backup purpose.

Change the config.ini accordingly:

```ini
[common]
server = "https://docs.getgrist.com/"
docId = "myDocId"
apiKey = "myApiKey"
documentName = "myDocumentName"
downloadDir = backups


[downloads]
downloadXLSX = true
downloadSQLITE = true
downloadCSV = true

[csvtables]
Table1
Table2
```

then run the downloadGrist executable.
The downloaded files will have a timestamp,
so its safe to run the tool over and over again.


