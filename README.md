# themer

Nim scripts used to dynamically change application themes. For example, you can change your i3, i3status, kitty terminal, vim themes from 'Nord' to 'Dracula' all at once

Some applications have direct support for live reload/refresh (alacritty, kitty, i3). Others have other methods of dynamid updating like xterm, etc

At the moment, correct behavior depends heavily on user setup (with my dotfiles). More specifically, it expects to see ~/.config/$program/themes/$theme.theme.conf

## Usage

```sh
git clone https://github.com/eankeen/themer
cd themer
nimble install
```


