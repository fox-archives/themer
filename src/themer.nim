#!/usr/bin/env -S nim r
import os
import terminal
import parseopt
import system
import terminal
# import exitprocs
import "./util"
import "./update"

system.addQuitProc(resetAttributes)
# addExitProc(resetAttributes)

const themes = [
  "nord",
  "dracula"
]
const programs = [
  "xterm",
  "alacritty",
  "kitty",
  "i3",
  "rofi",
  "dircolors"
]

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
  else:
    warn "No matching program found. Exiting"
    quit QuitFailure

proc doAll(theme: string) =
  updateXResources(theme) # broken
  updateAlacritty(theme)
  updateTermite(theme)
  updateKitty(theme)
  # updateVscode(theme) # broken
  updatei3(theme)
  updateRofi(theme)
  updateDircolors(theme)


var program = ""
var theme = ""
var tty = false

var p = initOptParser(commandLineParams())
while true:
  p.next()
  case p.kind:
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    case p.key:
      of "help", "h": writeHelp(); quit QuitSuccess
      of "version", "v": writeVersion(); quit QuitSuccess
      of "program":
        program = p.val
      of "theme":
        theme = p.val
      of "tty":
        tty = true
  of cmdArgument:
    discard
  #   echo "Argument: ", p.key

if theme == "":
  if tty:
    theme = promptTty(@themes)
  else:
    theme = promptGraphical(@themes)


if theme == "":
  error "Theme should not be blank. Exiting"
  quit QuitFailure

if program == "":
  doAll(theme)
elif program == "choose":
  if tty:
    program = promptTty(@programs)
  else:
    program = promptGraphical(@programs)
else:
  doProgram(program, theme)

quit QuitSuccess
