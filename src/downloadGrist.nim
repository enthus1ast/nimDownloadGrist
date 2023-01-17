import parsecfg, strutils, strformat, os, tables
import times
import gristapi

var config = loadConfig(getAppDir() / "config.ini")

var grist = newGristApi(
  server = config.getSectionValue("common", "server"),
  docId = config.getSectionValue("common", "docId"),
  apiKey = config.getSectionValue("common", "apiKey")
)

let documentName = config.getSectionValue("common", "documentName")
let dateStr = ($now()).replace(":", "-")

let downloadDirConfig = config.getSectionValue("common", "downloadDir")
let downloadDir =
  if downloadDirConfig.isAbsolute(): downloadDirConfig
  else: getAppDir() / downloadDirConfig
if not dirExists(downloadDir):
  createDir(downloadDir)

if config.getSectionValue("downloads", "downloadSQLITE").parseBool():
  let dataSqlite = grist.downloadSQLITE()
  writeFile(downloadDir / fmt"{documentName}__{dateStr}.sqlite", dataSqlite)

if config.getSectionValue("downloads", "downloadXLSX").parseBool():
  let dataXLSX = grist.downloadXLSX()
  writeFile(downloadDir / fmt"{documentName}__{dateStr}.xlsx", dataXLSX)

if config.getSectionValue("downloads", "downloadCSV").parseBool():
  for csvtable in config["csvtables"].keys():
    let dataCSV = grist.downloadCSV(csvtable)
    writeFile(downloadDir / fmt"{documentName}-{csvtable}__{dateStr}.csv", dataCSV)