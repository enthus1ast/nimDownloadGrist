# Package

version       = "0.2.1"
author        = "David Krause"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["nimGristDownload"]


# Dependencies

requires "nim >= 1.6.10"
requires "https://github.com/enthus1ast/nimGristApi"
requires "https://github.com/enthus1ast/formatja"

task win, "build for windows":
  exec "nim c -d:release --opt:speed --gc:arc -d:lto --passl:-s --out=releases/downloadGrist src/downloadGrist.nim"