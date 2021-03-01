#!/usr/bin/env -S nim r
import os
import osproc
import strutils
import terminal
import rdstdin
import parseopt
import "./update"

const VERSION {.strdefine.} = "unknown"

proc writeHelp() =
  echo "--theme, --program"

proc writeVersion() =
  echo VERSION

proc doProgram(programName: string, theme: string) =
  case programName:
  of "xterm":
    updateXResources(theme) # broken
  of "urxvt":
    updateXResources(theme) # broken
  of "alacritty":
    updateTermite(theme)
  of "kitty":
    updateKitty(theme)
  of "i3":
    updatei3(theme)
  of "rofi":
    updateRofi(theme)
  of "dircolors":
    updateDircolors(theme)

proc readTheme(): string =
  var theme = ""
  if isatty(stdin):
    theme = readLineFromStdin("New theme?: ")
  else:
    theme = readAll(stdin)
  theme = theme.strip()
  if theme == "":
    echo "Theme not valid"
    quit(QuitFailure)

proc readThemeGraphical(): string =
  let tup = execCmdEx("dmenu", options={poEchoCmd, poUsePath}, input = "nord\ndracula")
  echo tup
  if tup.exitCode != 0:
    echo "Exit code not 0. Exiting"
    quit QuitFailure

  return tup.output.strip()

var program = ""
var theme = ""
var graphical = false

var p = initOptParser(commandLineParams())
while true:
  p.next()
  case p.kind:
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    case p.key
      of "help", "h": writeHelp(); quit QuitSuccess
      of "version", "v": writeVersion(); quit QuitSuccess
      of "program":
        program = p.val
      of "theme":
        theme = p.val
      of "graphical":
        graphical = true
  of cmdArgument:
    echo "Argument: ", p.key

if not graphical:
  if theme == "":
    theme = readTheme()
else:
  if theme == "":
    theme = readThemeGraphical()

if program != "":
  doProgram(program, theme)
  quit QuitSuccess

if theme == "":
  echo "Theme should not be blank"
  quit QuitFailure

updateXResources(theme) # broken
updateAlacritty(theme)
updateTermite(theme)
updateKitty(theme)
# updateVscode(theme) # broken
updatei3(theme)
updateRofi(theme)
updateDircolors(theme)
