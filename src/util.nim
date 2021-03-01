import os
import strformat
import strutils

proc getCfg*(): string =
  if getEnv("XDG_CONFIG_HOME") != "":
    return getEnv("XDG_CONFIG_HOME")
  return joinPath(getEnv("HOME"), ".config")

proc getRuntimeDir*(): string =
  if getEnv("XDG_RUNTIME_DIR") != "":
    return getEnv("XDG_RUNTIME_DIR")
  raise newException(Defect, "XDG_RUNTIME_DIR not found")

proc getThemerDeclarations*(fileContent: string): seq[string] =
  const comment = "#"
  var declarations: seq[string] = @[]

  var n = 1
  while true:
    let startSubstr = &"{comment} THEMER-BEGIN-{n}\n"
    let startIndex = find(fileContent, startSubstr)

    let endSubstr = &"{comment} THEMER-END-{n}\n"
    let endIndex = find(fileContent, endSubstr)

    if startIndex == -1 or endIndex == -1:
      return declarations

    let catch = fileContent[startIndex + len(startSubstr) .. endIndex - 2]
    declarations.add(catch)

    n = n + 1

  return declarations

proc insertThemerDeclarations*(originalFileContent: string, declarations: seq[string]): string =
  const comment = "#"
  var fileContent = originalFileContent

  var n = 1
  while true:
    let startSubstr = &"{comment} THEMER-BEGIN-{n}\n"
    let startIndex = find(fileContent, startSubstr)

    let endSubstr = &"{comment} THEMER-END-{n}\n"
    let endIndex = find(fileContent, endSubstr)

    if startIndex == -1 or endIndex == -1:
      return fileContent

    let s = startIndex + len(startSubstr) - 1
    let e = endIndex - 1
    fileContent = fileContent[0 .. s] & declarations[n - 1] & fileContent[e .. ^1]
    n = n + 1

  return fileContent
