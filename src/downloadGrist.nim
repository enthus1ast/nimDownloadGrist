import parsecfg, strutils, strformat, os, tables, uri, sequtils
import times
import gristapi
import formatja
import glob
import std/logging
import sets

const VERSION {.strdefine.} = "-1"

var consoleLog = newConsoleLogger(fmtStr="[$time] - $levelname: ")
addHandler(consoleLog)

when defined(posix) or defined(linux):
  import loggingPosix
  var syslogLog = newSyslogLogger(
    fmtStr = "$levelname: "
  )
  addHandler(syslogLog)

else:
  var logfile = getAppDir() / "downloadGrist.log"
  open(logfile, fmWrite).close() # create the logfile
  var rollingLog = newRollingFileLogger(
    logfile,
    fmtStr = "[$time] - $levelname: ",
    mode = fmReadWriteExisting
  )  
  addHandler(rollingLog)


proc downloadWithConfig(configPath: string) =

  var config = loadConfig(configPath)
  var grist = newGristApi(
    server = config.getSectionValue("common", "server"),
    docId = config.getSectionValue("common", "docId"),
    apiKey = config.getSectionValue("common", "apiKey"),
  )
  let documentName = config.getSectionValue("common", "documentName")

  info(
    format("Version: {{version}} Server: '{{server}}' name: '{{documentName}}' docId: '{{docId}}' apiKey: '{{apiKey}}'", {
      "server": $grist.server,
      "documentName": documentName, 
      "docId": $grist.docId,
      "apiKey": $grist.apiKey,
      "version": VERSION
    }))

  if $grist.server == "" or grist.docId == "" or grist.apiKey == "":
    error "Please specify the 'server' the 'docId' and the 'apiKey' in the configuration."
    quit(1)

  var replacer: Replacer = {
    "documentName": config.getSectionValue("common", "documentName"),
    "dateStr": ($now()).replace(":", "-")
  }.toTable

  let downloadDirConfig = config.getSectionValue("common", "downloadDir")
  let downloadDir =
    if downloadDirConfig.isAbsolute(): downloadDirConfig
    else: getAppDir() / downloadDirConfig
  if not dirExists(downloadDir):
    createDir(downloadDir)

  if config.getSectionValue("downloads", "downloadSQLITE").parseBool():
    info "Download sqlite"
    try:
      let dataSqlite = grist.downloadSQLITE()
      let format = config.getSectionValue("format", "formatSQLITE")
      writeFile(downloadDir / format(format, replacer), dataSqlite)
    except:
      error format("Could not download sqlite: '{{msg}}'", {"msg": getCurrentExceptionMsg()})

  if config.getSectionValue("downloads", "downloadXLSX").parseBool():
    info "Download xlsx"
    try:
      let dataXLSX = grist.downloadXLSX()
      let format = config.getSectionValue("format", "formatXLSX")
      writeFile(downloadDir / format(format, replacer), dataXLSX)
    except:
      error format("Could not download xlsx: '{{msg}}'", {"msg": getCurrentExceptionMsg()})


  if config.getSectionValue("downloads", "downloadCSV").parseBool():
    let format = config.getSectionValue("format", "formatCSV")

    # If the csvtables contains a wildcard, we have to first
    # download a list of all tables, then match on them.

    let anyHasGlob = toSeq(config["csvtables"].keys()).any(
      proc (x: string): bool =
        x.hasMagic()
    )

    var csvsToDownload: HashSet[string]
    if anyHasGlob:
      # At least one entry is a glob, get the table list.
      var tableNames = grist.listTableNames()
      for matcherStr in config["csvtables"].keys():
        if not matcherStr.hasMagic():
          # Not a glob, just add it
          csvsToDownload.incl matcherStr
        else:
          # A glob, look through all tableName if the given glob matches.
          let pattern = glob(matcherStr)
          for tableName in tableNames:
            if tableName.matches(pattern):
              csvsToDownload.incl(tableName)
    else:
      # No entry is a glob, just add
      for matcherStr in config["csvtables"].keys():
        csvsToDownload.incl matcherStr

    for csvtable in csvsToDownload:
      info format("Download csv table: '{{csvtable}}'", {"csvtable": csvtable})
      try:
        replacer["csvtable"] = csvtable
        let dataCSV = grist.downloadCSV(csvtable)
        writeFile(downloadDir / format(format, replacer), dataCSV)
      except:
        error format("Could not download csv table {{csvtable}}: {{msg}}", {
          "msg": getCurrentExceptionMsg(),
          "csvtable": csvtable
        })


let configPath = getConfigDir() / "downloadGrist.ini"
let configDir = getConfigDir() / "downloadGrist"

if not dirExists(configDir):
  warn fmt"configdir ({configDir}) is missing, i'll create it for you! Quitting."
  createDir(configDir)
  quit(1)

# Run the config from the single config file
if fileExists(configPath):
  info fmt"Config: {configPath}"
  downloadWithConfig(configPath)

# Run all the configs from the config dir
for configPath in walkFiles(configDir / "*.ini"):
  info fmt"Config: {configPath}"
  downloadWithConfig(configPath)