# Package

version       = "0.3.2"
author        = "David Krause"
description   = "Tool to backup grist documents"
license       = "MIT"
srcDir        = "src"
bin           = @["nimGristDownload"]


# Dependencies

requires "nim >= 1.6.10"
requires "https://github.com/enthus1ast/nimGristApi"
requires "https://github.com/enthus1ast/formatja"
requires "glob"
requires "ziggcc"

import formatja

let crossCompileWithZig = """nim c -d:release -d:VERSION={{version}} --cpu:{{cpu}} --cc:clang --clang.exe="zigcc.cmd" --clang.linkerexe="zigcc.cmd" --passc:"-target {{target}}" --passl:"-target {{target}}" --forceBuild:on --os:{{os}} --opt:speed  --out:builds/downloadGrist_{{version}}_{{target}}{{ext}} src/downloadGrist.nim"""

task win, "build for windows (default compiler)":
  exec "nim c -d:release --opt:speed --gc:arc -d:lto --passl:-s --out=releases/downloadGrist src/downloadGrist.nim"

# task crossfreebsd, "build from windows for linux (zig)":
task crosswindows, "build from windows for windows (zig)":
  block:
    let target = "x86_64-windows-gnu"
    let cmd = format(crossCompileWithZig, {"target": target, "os": "windows", "cpu": "amd64", "ext": ".exe", "version": version})
    echo cmd
    exec cmd

task crosslinux, "build from windows for linux (zig)":
  block:
    let target = "x86_64-linux-gnu"
    let cmd = format(crossCompileWithZig, {"target": target, "os": "linux", "cpu": "amd64", "version": version})
    echo cmd
    exec cmd

task crossarm, "build from windows for linux arm (zig)":
  for target in ["arm-linux-gnueabi", "arm-linux-gnueabihf"]:
    let cmd = format(crossCompileWithZig, {"target": target, "os": "linux", "cpu": "arm", "version": version})
    echo cmd
    exec cmd
  for target in ["aarch64-linux-gnu"]:
    let cmd = format(crossCompileWithZig, {"target": target, "os": "linux", "cpu": "arm64", "version": version})
    echo cmd
    exec cmd

task release, "build for all supported targets":
  crosswindowsTask()
  crosslinuxTask()
  crossarmTask()


## If someone wants to build this on macos you must do it yourself, i cannot test it, do not own a mac,
## and i dont want to put effort in this as well,
## I'm also not jumping through Apples stupid loops to build for their ¥€$ os....
## Something like this could work idk:
# task crossmacos, "build from windows for macos (zig)":
#   block:
#     let target = "x86_64-macos-none"
#     let cmd = format(crossCompileWithZig, {"target": target, "os": "MacOSX", "cpu": "amd64"})
#     echo cmd
#     exec cmd
#   block:
#     let target = "aarch64-macos-none"
#     let cmd = format(crossCompileWithZig, {"target": target, "os": "MacOSX", "cpu": "arm64"})
#     echo cmd
#     exec cmd