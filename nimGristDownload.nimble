# Package

version       = "0.1.0"
author        = "David Krause"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["nimGristDownload"]


# Dependencies

requires "nim >= 1.6.10"
requires "https://github.com/enthus1ast/nimGristApi"
