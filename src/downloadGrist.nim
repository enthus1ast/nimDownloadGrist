import parsecfg, strutils, strformat, os, tables
import times
import gristapi
import formatja

var config = loadConfig(getAppDir() / "config.ini")

var grist = newGristApi(
  server = config.getSectionValue("common", "server"),
  docId = config.getSectionValue("common", "docId"),
  apiKey = config.getSectionValue("common", "apiKey")
)


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
  let dataSqlite = grist.downloadSQLITE()
  let format = config.getSectionValue("format", "formatSQLITE")
  writeFile(downloadDir / format(format, replacer), dataSqlite)

if config.getSectionValue("downloads", "downloadXLSX").parseBool():
  let dataXLSX = grist.downloadXLSX()
  let format = config.getSectionValue("format", "formatXLSX")
  writeFile(downloadDir / format(format, replacer), dataXLSX)

if config.getSectionValue("downloads", "downloadCSV").parseBool():
  let format = config.getSectionValue("format", "formatCSV")
  for csvtable in config["csvtables"].keys():
    replacer["csvtable"] = csvtable
    let dataCSV = grist.downloadCSV(csvtable)
    writeFile(downloadDir / format(format, replacer), dataCSV)