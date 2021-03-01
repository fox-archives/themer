import os
import osproc
import strformat
import strutils
import "./util"


proc updateXResources*(themeName: string) =
  echo "UPDATING XRESOURCES"
  let cfgDir = getCfg()
  let cfg = fmt"{cfgDir}/X11/Xresources"
  let themeDest = fmt"{cfgDir}/X11/themes/_.theme.Xresources"
  let themeSrc = fmt"{cfgDir}/X11/themes/{themeName}.theme.Xresources"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)
  discard execCmd(fmt"xrdb -load {cfg}")

  # live update

proc updateAlacritty*(themeName: string) =
  echo "UPDATING ALACRITTY"
  let cfgDir = getCfg()
  let cfg = fmt"{cfgDir}/alacritty/alacritty.yml"
  let themeDest = fmt"{cfgDir}/alacritty/themes/_.theme.yml"
  let themeSrc = fmt"{cfgDir}/alacritty/themes/{themeName}.theme.yml"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)
  let declarations = getThemerDeclarations(readFile(themeDest))
  writeFile(cfg, insertThemerDeclarations(readFile(cfg), declarations))


proc updateTermite*(themeName: string) =
  echo "UPDATING TERMITE"
  let cfgDir = getCfg()
  let cfg = fmt"{cfgDir}/termite/config"
  let themeDest = fmt"{cfgDir}/termite/themes/_.theme.conf"
  let themeSrc = fmt"{cfgDir}/termite/themes/{themeName}.theme.conf"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)
  let declarations = getThemerDeclarations(readFile(themeDest))
  writeFile(cfg, insertThemerDeclarations(readFile(cfg), declarations))

  # live update
  discard execCmd("killall -USR1 termite")

proc updateKitty*(themeName: string) =
  echo "UPDATING KITTY"
  let cfgDir = getCfg()
  let themeDest = fmt"{cfgDir}/kitty/themes/_.theme.conf"
  let themeSrc = fmt"{cfgDir}/kitty/themes/{themeName}.theme.conf"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)

  # live update (requires launching via ~/scripts/kitty.sh)
  for kind, path in walkDir(joinPath(getRuntimeDir(), "kitty")):
    if count(path, "control-socket-") > 0:
      discard execCmd(fmt"kitty @ --to=unix:{path} set-colors -a {themeDest}")

proc updateVscode*(themeName: string) =
  echo "UPDATING VSCODE"
  let cfgDir = getCfg()
  let cfg = fmt"{cfgDir}/Code/User/settings.json"

  let realThemeName = case themeName:
    of "nord":
      "Nord"
    of "dracula":
      "Dracula"
    else:
      echo "INVALID THEME"
      "Nord"

  # const cmd = &"file=\"/home/edwin/config/Code/User/settings.json\" content=\"$(cat \"$file\" | jq --arg theme \"Nord\" '.[\"workbench.colorTheme\"] = $theme')\"; cat >| \"$file\" <<< \"$content\""
  # discard execCmd(&"/bin/bash \"{cmd}\"")



proc updatei3*(themeName: string) =
  echo "UPDATING i3"
  let cfgDir = getCfg()
  let themeSrc = fmt"{cfgDir}/i3/themes/{themeName}.theme.conf"
  let themeDest = fmt"{cfgDir}/i3/themes/_.theme.conf"
  let cfg = fmt"{cfgDir}/i3/config"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)
  let declarations = getThemerDeclarations(readFile(themeDest))
  writeFile(cfg, insertThemerDeclarations(readFile(cfg), declarations))

  # live update
  discard execCmd("i3 reload")

proc updateRofi*(themeName: string) =
  echo "UPDATING ROFI"
  let cfgDir = getCfg()
  let themeSrc = fmt"{cfgDir}/rofi/themes/{themeName}.theme.rasi"
  let themeDest = fmt"{cfgDir}/rofi/themes/_.theme.rasi"
  let cfg = fmt"{cfgDir}/rofi/config.rasi"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)

proc updateDircolors*(themeName: string) =
  echo "UPDATING DIRCOLORS"
  let cfgDir = getCfg()
  let themeSrc = fmt"{cfgDir}/dircolors/themes/{themeName}.theme.dir_colors"
  let themeDest = fmt"{cfgDir}/dircolors/themes/_.theme.dir_colors"

  # perm update
  removeFile(themeDest)
  createSymlink(themeSrc, themeDest)
