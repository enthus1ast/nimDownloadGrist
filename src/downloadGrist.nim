import parsecfg, strutils, strformat, os, tables, uri
import times
import gristapi
import formatja
import std/logging

const VERSION {.strdefine.} = "-1"

func changeToPlatformNewlines(str: string): string =
  for line in str.splitLines():
    result.add line & "\p"

const defaultConfigFile = staticRead("config.ini.in").changeToPlatformNewlines()

var logfile = getAppDir() / "downloadGrist.log"
open(logfile, fmWrite).close() # create the logfile

var consoleLog = newConsoleLogger(fmtStr="[$time] - $levelname: ")
var rollingLog = newRollingFileLogger(
  logfile,
  fmtStr = "[$time] - $levelname: ",
  mode = fmReadWriteExisting
)
addHandler(consoleLog)
addHandler(rollingLog)

let configPath = getAppDir() / "config.ini"

if not fileExists(configPath):
  warn "config.ini is missing, i'll create it for you! Quitting."
  writeFile(configPath, defaultConfigFile)
  quit(1)

var config = loadConfig(getAppDir() / "config.ini")
# echo config

var grist = newGristApi(
  server = config.getSectionValue("common", "server"),
  docId = config.getSectionValue("common", "docId"),
  apiKey = config.getSectionValue("common", "apiKey")
)

info(
  format("Version: {{version}} Server: '{{server}}' docId: '{{docId}}' apiKey: '{{apiKey}}'", {
    "server": $grist.server,
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
  for csvtable in config["csvtables"].keys():
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
