# Fastfetch dotfiles

A portable copy of the custom Fastfetch setup used on an Omarchy Linux
(Hyprland) machine. It contains the Fastfetch configuration, the full image
collection, the `fastfetch-image` command, and notes for the Omarchy "About"
integration.

The repository is intentionally limited to Fastfetch-related files. It does not
contain a full Hyprland, shell, or Omarchy configuration.

## Contents

```text
dotfiles/
├── README.md
├── install.sh
├── .gitignore
├── fastfetch/
│   ├── config.jsonc
│   ├── current-image -> images/israrkhan-cys/3.png
│   └── images/
│       └── israrkhan-cys/
│           ├── 1.png
│           ├── 2.png
│           ├── 3.png
│           ├── ...
│           └── zerotwo.png
├── scripts/
│   └── fastfetch-image
└── omarchy/
    └── about-window.lua
```

## Discovered custom features

### 1. Custom Fastfetch configuration

File: `fastfetch/config.jsonc` → installed at `~/.config/fastfetch/config.jsonc`

This is the active user configuration. Its main customizations are:

- An image logo using the terminal's Kitty graphics protocol
  (`"type": "kitty"`), width `27` columns, top padding `4`, right padding `6`.
- The logo source is the portable path
  `~/.config/fastfetch/current-image`.
- Two colored dot rows made with a `custom` module.
- A compact module list: title, OS, kernel, packages, shell, terminal, window
  manager, cursor, terminal font, uptime, and date.
- Custom key glyphs and blue key colors.
- Date format `{1}-{3}-{11}`.
- No line-wrapping changes, no custom ASCII logo, and no Omarchy branding file
  dependency.

The only change made for portability is the logo path: the original used
`/home/<user>/.config/fastfetch/current-image`, and this copy uses the
`~/.config/fastfetch/current-image` form already supported by Fastfetch.

### 2. Image collection and active image

Directory: `fastfetch/images/israrkhan-cys/` → installed at
`~/.config/fastfetch/images/israrkhan-cys/`

The collection contains 20 PNG/JPEG images. The active image is stored in the
relative symlink `fastfetch/current-image`, which currently points to
`images/israrkhan-cys/3.png`. A relative symlink keeps the repository portable;
`fastfetch-image` also writes relative links after this change.

The two duplicate images that were stored directly in `~/.config/fastfetch/`
(`1.png` and `h3.png`) are not duplicated in this repository. Identical copies
already exist in the collection, and the active configuration does not use the
top-level copies.

### 3. `fastfetch-image` command

File: `scripts/fastfetch-image` → installed at `~/.local/bin/fastfetch-image`

This is the main custom command. It manages the image collection and keeps the
Fastfetch logo width/top padding balanced against the module output.

Supported commands:

| Command | What it does |
| --- | --- |
| `fastfetch-image` | Opens an `fzf` picker, marks the current image, applies the selection, recalculates the logo size/padding, and runs Fastfetch. |
| `fastfetch-image IMAGE` | Applies a specific file name from the collection, such as `fastfetch-image 3.png`. |
| `fastfetch-image --size up` | Increases the logo width by 2 columns (maximum 48). |
| `fastfetch-image --size down` | Decreases the logo width by 2 columns (minimum 6). |
| `fastfetch-image --size COLUMNS` | Sets an explicit width between 6 and 48 columns. |
| `fastfetch-image --add FILE [NAME]` | Adds a local PNG/JPEG to the collection. `NAME` is optional; the extension is chosen automatically. |
| `fastfetch-image --add URL [NAME]` | Downloads a PNG/JPEG over HTTP(S), up to 25 MiB. |
| `fastfetch-image --remove [IMAGE]` | Removes an image after confirmation. Without `IMAGE`, uses `fzf`; if the active image is removed, it switches to another image. |
| `fastfetch-image --list` | Lists the collection. |
| `fastfetch-image --help` | Shows usage. |

Implementation details worth knowing:

- The collection directory is intentionally hard-coded as
  `israrkhan-cys`; renaming it requires updating the script.
- `--add` accepts only PNG and JPEG, limits each side to 10,000 px and the total
  to 40 megapixels, and rejects names containing anything except letters,
  numbers, `_`, and `-`.
- `--remove` refuses to remove the last remaining image.
- The script keeps at least one image so the logo never disappears.
- `--size` and image selection estimate the rendered image height using the
  current Fastfetch module row count and a `0.52` aspect-ratio factor. This was
  tuned for the current terminal font; it is not a universal pixel-perfect
  calculation.
- `hypr.png` receives one extra row of top padding, matching the existing
  behavior.
- The script uses `readlink -f` to compare canonical paths. This is important
  because the installer may make `~/.config/fastfetch` a symlink to the
  repository.

### 4. Omarchy "About" integration

Omarchy's About menu item runs `omarchy-launch-about`. That command uses
`~/.config/fastfetch/config.jsonc` when a user configuration exists. Therefore
the same configuration is used by both the `fastfetch` command and the Omarchy
About window.

This setup also has a custom Hyprland rule for the About window: `620 × 400`
instead of the Omarchy default `920 × 480`. The current machine pins terminal
and About windows to full opacity so that the image logo stays crisp when the
"Glass & Blur" plugin is active.

These are Hyprland appearance changes, not Fastfetch configuration, so they are
**not installed automatically**. `omarchy/about-window.lua` contains the small
About-size snippet. Merge it into `~/.config/hypr/hyprland.lua` or require it
from there if you want the same window size. The full glass/opacity rules on the
original machine are broader terminal rules and are intentionally left out of
this repository.

### 5. Shell setup

No Fastfetch aliases or shell functions were found. The command works because
`~/.local/bin` is on `PATH`.

On Omarchy, `/usr/share/omarchy/default/bash/env-bootstrap` adds
`~/.local/bin` automatically. The existing shell files source that bootstrap or
the equivalent path setup:

- `~/.bashrc` sources the Omarchy environment and `~/.local/bin/env`.
- `~/.zshrc`, `~/.profile`, and `~/.bash_profile` source
  `~/.local/share/../bin/env`.

No shell configuration change is required on a normal Omarchy installation. On
a non-Omarchy machine, add this to the shell startup file:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## Requirements

### Required for the main display

- `fastfetch` — tested with 2.70.0
- A terminal that supports the Kitty graphics protocol for the image logo:
  Ghostty, Kitty, or another compatible terminal. The current configuration uses
  `"type": "kitty"`.
- Nerd Font glyphs for the icons and colored-dot module.

### Required for `fastfetch-image`

- `bash`
- `imagemagick` (the `magick` command)
- `python` (the script calls `python`, not `python3`)
- `fzf` — interactive image picker and interactive removal
- `curl` — `--add URL`
- Standard GNU tools: `find`, `sort`, `readlink`, `stat`, `awk`, `wc`, `ln`,
  `rm`, `mv`, `mktemp`

Install the Arch/Omarchy packages with:

```sh
sudo pacman -S --needed fastfetch imagemagick python fzf curl
```

The installer checks for these commands but never installs packages
automatically.

### Terminal fallback

The image logo uses the Kitty protocol. On a terminal without Kitty graphics,
change the `logo` block in `~/.config/fastfetch/config.jsonc` to a supported
type, for example:

```jsonc
"type": "sixel"
```

for a sixel-capable terminal such as foot, or:

```jsonc
"type": "chafa"
```

with `chafa` installed. The `fastfetch-image` size/padding calculations still
work because they only read and update the logo width and top padding. The
visual result will differ from the Kitty version.

## Installation on a fresh Omarchy machine

1. Install the dependencies listed above.
2. Clone or copy this directory to the new machine. The examples below use
   `~/dotfiles`.
3. Run the installer:

   ```sh
   cd ~/dotfiles
   ./install.sh
   ```

4. Open a new terminal, or make sure `~/.local/bin` is on `PATH`, then run:

   ```sh
   fastfetch
   fastfetch-image --list
   ```

The installer:

- Links `~/dotfiles/fastfetch` to `~/.config/fastfetch`.
- Links `~/dotfiles/scripts/fastfetch-image` to
  `~/.local/bin/fastfetch-image`.
- Creates `current-image` if it is missing.
- Backs up any existing target as `<target>.bak.<timestamp>` before replacing
  it. It never deletes an existing configuration.
- Is idempotent: a second run detects the existing links and makes no changes.
- Does not modify shell startup files, Hyprland configuration, or Omarchy
  configuration.
- Does not install packages.

If `~/.config/fastfetch` already exists, its full contents are moved to a backup
directory. You can copy any extra personal images from that backup into
`~/dotfiles/fastfetch/images/israrkhan-cys/` and re-run `fastfetch-image`.

### Manual installation

If you do not want symlinks, copy the files instead:

```sh
mkdir -p ~/.config/fastfetch ~/.local/bin
cp -a fastfetch/. ~/.config/fastfetch/
cp scripts/fastfetch-image ~/.local/bin/fastfetch-image
chmod 755 ~/.local/bin/fastfetch-image
```

Manual copies are not automatically updated when the repository changes.

### Optional Omarchy About window size

To preserve the current About window size, merge
`omarchy/about-window.lua` into your Hyprland configuration. For example:

```sh
mkdir -p ~/.config/hypr
cp omarchy/about-window.lua ~/.config/hypr/fastfetch-about.lua
```

Then add this line to `~/.config/hypr/hyprland.lua` after the Omarchy defaults:

```lua
require("hypr.fastfetch-about")
```

This step is optional and is not performed by `install.sh`.

## Daily use and updating the dotfiles

Because `~/.config/fastfetch` is a symlink to this repository, changes made with
`fastfetch-image` or by editing
`~/.config/fastfetch/config.jsonc` are changes inside the repository.

After changing anything:

```sh
cd ~/dotfiles
git status
git add fastfetch scripts README.md install.sh omarchy .gitignore
git commit -m "Update Fastfetch configuration"
```

`fastfetch-image --add` writes new images into
`fastfetch/images/israrkhan-cys/`, so commit those files too. The `current-image`
symlink is also tracked; commit it when the active image changes.

If you use the manual-copy installation instead, copy your changed files back
into the repository before committing.

## Rollback

The installer creates timestamped backups next to the replaced targets, for
example:

```text
~/.config/fastfetch.bak.20261024-235040/
~/.local/bin/fastfetch-image.bak.20261024-235040
```

To restore the previous setup, remove the two symlinks and move the backups back:

```sh
rm ~/.config/fastfetch ~/.local/bin/fastfetch-image
mv ~/.config/fastfetch.bak.<timestamp> ~/.config/fastfetch
mv ~/.local/bin/fastfetch-image.bak.<timestamp> ~/.local/bin/fastfetch-image
```

## Limitations and machine-specific notes

- The image logo requires a Kitty-graphics terminal. The actual image rendering
  could not be verified in a plain non-graphics test environment; configuration
  parsing and the underlying commands were verified.
- The interactive `fzf` picker and interactive removal were exercised with a
  stub `fzf` in an isolated copy, including the current-image marker and
  automatic switching. The real `fzf` full-screen UI was not visually inspected
  in this non-interactive test environment.
- `fastfetch-image` uses `$HOME/.config/fastfetch` directly and does not honor
  `XDG_CONFIG_HOME`. This matches the Omarchy layout.
- The repository's `current-image` symlink is the default selection (`3.png`).
  The installer does not import a different active image from a backed-up
  configuration; use `fastfetch-image` after installation if you want another
  image.
- The collection name `israrkhan-cys` is part of the script. Renaming the
  directory requires updating `image_dir` and the relative symlink target in the
  script.
- The `0.52` aspect-ratio factor and the `hypr.png` extra-padding special case
  are tuned to the current setup. Different terminal fonts or image aspect
  ratios may need a small `--size` adjustment.
- The optional About window size and glass/opacity rules are Hyprland settings,
  not Fastfetch settings. They are documented but not installed automatically.
- The original `config.jsonc.bak.*` files and the backup copy of
  `fastfetch-image` were not included in the repository. They are development
  backups, not active configuration.

## Related files intentionally not included

These files were found during inspection but are not part of the Fastfetch
configuration, so they are not installed by this repository:

- `~/.local/bin/ghostty-glass-sync` plus its Hyprland autostart entry and Ghostty
  `glass.conf` include. This helper keeps Ghostty's background opacity in sync
  with the "Glass & Blur" plugin and keeps terminal text and inline images
  crisp. It is a Ghostty/Hyprland appearance helper, not a Fastfetch command.
- The Hyprland opacity/glass rules that pin terminals and the About window to
  full opacity. They are broader terminal rules and are machine-specific.
- `~/.config/omarchy/branding/about.txt` and `screensaver.txt`. The active
  Fastfetch configuration uses its own image logo, so the About branding file is
  not used for this setup. The screensaver branding is unrelated.
- `~/.config/fastfetch/config.jsonc.bak.*`, the backup copy of
  `fastfetch-image`, and the duplicate top-level images `1.png` and `h3.png`.

## Verification performed

The following checks were run against this repository:

- `bash -n` on `install.sh` and `scripts/fastfetch-image`: passed.
- `shellcheck` on both scripts: no errors; only one pre-existing informational
  warning about a literal backtick in a single-quoted `printf` message.
- `fastfetch --config fastfetch/config.jsonc --logo none --pipe`: exits 0 and
  produces the expected 20-line module layout.
- All 20 collection images were opened with `magick identify`: all valid
  PNG/JPEG files.
- Installer tested against a fresh fake home and against a fake home with
  existing conflicting files: backups were created, target links were correct,
  and dependencies were checked.
- Installer run twice: second run made no new backups and kept the same links.
- `fastfetch-image --list`, `--help`, direct image selection, `--size up`,
  `--size down`, `--size 6`, `--size 49` rejection, invalid size rejection,
  unknown image rejection, local `--add`, HTTP `--add` against a local test
  server, duplicate rejection, `--remove` with confirmation, unknown removal
  rejection, removal of the currently active image (including automatic
  switch), and last-image removal protection were tested in an isolated copy.
- The interactive selection and interactive removal paths were tested with a
  stub `fzf`, including the current-image marker. The actual full-screen `fzf`
  UI was not visually inspected.
- The original `~/.config/fastfetch` and `~/.local/bin/fastfetch-image` were not
  modified.

## Publishing to GitHub later

This repository has not been committed or pushed. When ready:

```sh
cd ~/dotfiles
git init
git add .
git commit -m "Add portable Fastfetch dotfiles"
```

Create the GitHub repository and push it with GitHub CLI:

```sh
gh repo create fastfetch-dotfiles --public --source=. --remote=origin --push
```

Or create an empty repository on GitHub manually, then:

```sh
git remote add origin git@github.com:<your-user>/fastfetch-dotfiles.git
git branch -M main
git push -u origin main
```
