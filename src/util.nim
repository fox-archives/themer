import os
import strformat
import strutils
import terminal
import rdstdin
import osproc

proc error*(str: string) =
  echo fmt"{ansiForegroundColorCode(fgRed)}Error: {str}"
  resetAttributes()

proc warn*(str: string) =
  echo fmt"{ansiForegroundColorCode(fgYellow)}Info: {str}"
  resetAttributes()

proc info*(str: string) =
  echo fmt"{ansiForegroundColorCode(fgBlue)}Info: {str}"
  resetAttributes()

proc writeHelp*() =
  echo """themer

Summary:
  Utility for changing themes of multiple applications / programs in unison.

Options:
  --theme
    Theme to change to
  --program
    Only specify a particular program to change
  --tty
    Do prompts on the command line"""


const VERSION {.strdefine.} = "unknown"
proc writeVersion*() =
  echo VERSION

proc promptTty*(options: seq[string]): string =
  echo(fmt"Choose one: {options}")

  var response = ""
  if isatty(stdin):
    response = readLineFromStdin("")
  else:
    response = readAll(stdin)

  response = response.strip()

  if response == "":
    return promptTty(options)
  return response

proc promptGraphical*(options: seq[string]): string =
  let cmd = execCmdEx("dmenu", options={poUsePath}, input = options.join("\n"))

  if cmd.exitCode != 0:
    error "Could not get selection from graphical interface. Exiting"
    quit QuitFailure

  return cmd.output.strip()

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
