# FasftechDotfiles

A portable copy of my custom [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
setup for **Omarchy Linux**. It reproduces the Fastfetch layout, the Kitty
graphics image logo, the image collection, and the `fastfetch-image` command on
another Omarchy computer.

The repository contains only Fastfetch-related files. It does **not** replace a
full shell, Hyprland, Ghostty, or Omarchy configuration.

## Features

### Fastfetch appearance

The active configuration is `fastfetch/config.jsonc`, installed as
`~/.config/fastfetch/config.jsonc`.

It preserves the current setup:

- An image logo rendered with the **Kitty graphics protocol**
  (`"type": "kitty"`), width `27` columns, top padding `4`, right padding `6`.
- Two rows of colored dots created with a `custom` module.
- A compact system layout: title, OS, kernel, packages, shell, terminal, window
  manager, cursor, terminal font, uptime, and date.
- Custom Nerd Font key glyphs and blue key colors.
- Date format `{1}-{3}-{11}`.
- The logo source is the portable path
  `~/.config/fastfetch/current-image`; no username or absolute home directory
  is stored in the configuration.

### Image collection and active image

The collection is `fastfetch/images/israrkhan-cys/` and contains **20** PNG/JPEG
images. The repository's `fastfetch/current-image` is a relative symlink to
`images/israrkhan-cys/3.png`. The active image on the machine this repository was
created from is also `3.png`.

Two additional images in the original `~/.config/fastfetch/` directory (`1.png`
and `h3.png`) are byte-identical duplicates of files already in the collection.
They are intentionally not duplicated in the repository.

### `fastfetch-image` command

`scripts/fastfetch-image` is installed as `~/.local/bin/fastfetch-image`. It
manages the collection and keeps the logo width and top padding aligned with the
Fastfetch module output.

```text
fastfetch-image                         Choose an image with fzf
fastfetch-image IMAGE                   Select a specific image file
fastfetch-image --size up|down|COLUMNS  Resize the active image
fastfetch-image --add FILE_OR_URL [NAME] Add a local or online PNG/JPEG
fastfetch-image --remove [IMAGE]        Remove an image from the collection
fastfetch-image --list                  List available images
fastfetch-image --help                  Show help
```

Details:

- With no argument, `fastfetch-image` opens an `fzf` picker and marks the current
  image. The picker shows each image's dimensions.
- Selecting an image updates `current-image`, recalculates the logo width and
  top padding, and runs Fastfetch.
- `--size up` and `--size down` change the width by 2 columns. An explicit width
  from `6` to `48` is also accepted.
- `--add` accepts local files or HTTP(S) URLs. Only PNG and JPEG are accepted.
  Downloads are limited to 25 MiB; images may be at most 10,000 px per side and
  40 megapixels total. Names may contain letters, numbers, `_`, and `-`.
- `--remove` asks for confirmation and refuses to remove the last remaining
  image. If the active image is removed, it switches to another image.
- `--list` prints the collection without changing anything.
- The script prefers `python`, falls back to `python3`, and uses ImageMagick's
  `magick identify` for image dimensions.
- Image selection writes a **relative** `current-image` symlink so the
  repository remains portable when cloned into a different home directory.
- `hypr.png` receives one extra row of top padding, matching the existing setup.
- The `0.52` aspect-ratio factor in the size calculation was tuned for this
  terminal and font; a different font may need a small `--size` adjustment.

### Omarchy About integration

Omarchy's **About** menu item runs `omarchy-launch-about`, which uses
`~/.config/fastfetch/config.jsonc` when a user configuration exists. The same
Fastfetch layout therefore appears in both the terminal and the About window.

The original machine also uses a smaller About window (`620 × 400`) instead of
Omarchy's default size. That is an optional Hyprland customization and is kept
separate from the core Fastfetch installation; see
[Optional Omarchy integration](#optional-omarchy-integration).

## Repository structure

```text
dotfiles/
├── README.md
├── install.sh
├── .gitignore
├── fastfetch/
│   ├── config.jsonc
│   ├── current-image -> images/israrkhan-cys/3.png
│   └── images/
│       └── israrkhan-cys/        # 20 PNG/JPEG images
├── scripts/
│   └── fastfetch-image
└── omarchy/
    └── about-window.lua          # optional Hyprland snippet
```

- `fastfetch/config.jsonc` — active Fastfetch configuration.
- `fastfetch/current-image` — selected image; a relative symlink.
- `fastfetch/images/israrkhan-cys/` — complete image collection.
- `scripts/fastfetch-image` — image picker, resizer, and manager.
- `install.sh` — idempotent installer with backups.
- `omarchy/about-window.lua` — optional About window sizing, not installed by
  default.

## Requirements

### Required for Fastfetch

| Requirement | Purpose |
| --- | --- |
| `fastfetch` | Renders the configuration. Tested with 2.70.0. |
| A Kitty-graphics terminal | The logo uses `"type": "kitty"`. Ghostty and Kitty are compatible. |
| A Nerd Font | Provides the key glyphs and colored-dot symbols. |

The Kitty graphics protocol is a terminal feature; using the Kitty terminal is
not strictly required, but the terminal must support the protocol. Without it,
the text modules still render but the image logo will not appear correctly.

### Required for `fastfetch-image`

| Requirement | Purpose |
| --- | --- |
| `bash` | Runs the script. |
| `imagemagick` (`magick`) | Reads image formats and dimensions. |
| `python` or `python3` | Updates the logo width and padding in the JSONC file. |
| Standard GNU tools (`find`, `sort`, `readlink`, `awk`, `wc`, `mktemp`, etc.) | Collection and configuration handling. |

### Optional for `fastfetch-image`

| Requirement | Purpose |
| --- | --- |
| `fzf` | Interactive image selection and interactive removal. Direct image names work without it. |
| `curl` | `fastfetch-image --add URL`. Local files work without it. |

On Arch/Omarchy:

```sh
sudo pacman -S --needed fastfetch imagemagick python fzf curl
```

Omarchy's base installation normally provides `fastfetch`, `imagemagick`, and
`fzf`. The installer only checks for commands; it never installs packages.

### Terminal fallback

If you use a terminal without Kitty graphics, change the `logo` block in
`~/.config/fastfetch/config.jsonc` to a supported type, for example:

```jsonc
"type": "sixel"
```

for a sixel-capable terminal such as foot, or:

```jsonc
"type": "chafa"
```

with `chafa` installed. The `fastfetch-image` size and padding calculations still
work because they only read and update the logo width and top padding. The visual
result will differ from the Kitty version.

## Installation

### Fresh Omarchy installation

```sh
sudo pacman -S --needed fastfetch imagemagick python fzf curl

git clone https://github.com/MrUranium1/FasftechDotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh

exec bash
fastfetch
fastfetch-image --list
```

SSH clone:

```sh
git clone git@github.com:MrUranium1/FasftechDotfiles.git ~/dotfiles
```

`~/.local/bin` is added to `PATH` by Omarchy's environment bootstrap. If you use
another shell or a non-Omarchy system, add it manually:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### What the installer does

- Links the repository's `fastfetch/` directory to `~/.config/fastfetch`.
- Links `scripts/fastfetch-image` to `~/.local/bin/fastfetch-image`.
- Creates `current-image` if it is missing.
- Normalizes an absolute link into the repository's image collection to a
  relative link.
- Backs up any existing target before replacing it.
- Verifies that the installed configuration is readable, the command is
  executable, and `current-image` resolves.
- Is idempotent: running it again detects existing links and makes no changes.
- Does not modify shell startup files, Hyprland, Ghostty, or Omarchy settings.
- Does not install packages.

Backups use this naming scheme:

```text
~/.config/fastfetch.bak.YYYYMMDD-HHMMSS/
~/.local/bin/fastfetch-image.bak.YYYYMMDD-HHMMSS
```

If a name already exists, a numeric suffix is added.

If `~/.config/fastfetch` already exists, the whole directory is moved to the
backup before the symlink is created. Extra personal images can be copied from
that backup into `~/dotfiles/fastfetch/images/israrkhan-cys/` and committed.

### Manual installation

If you do not want symlinks:

```sh
mkdir -p ~/.config/fastfetch ~/.local/bin
cp -a fastfetch/. ~/.config/fastfetch/
cp scripts/fastfetch-image ~/.local/bin/fastfetch-image
chmod 755 ~/.local/bin/fastfetch-image
```

Manual copies do not update automatically when the repository changes.

## Image management

All commands use the collection at
`~/.config/fastfetch/images/israrkhan-cys/`.

### List images

```sh
fastfetch-image --list
```

### Select an image interactively

```sh
fastfetch-image
```

The current image is marked in the `fzf` list. Press Enter to apply a selection
or Esc to cancel.

### Select a specific image

```sh
fastfetch-image 3.png
```

### Resize the active image

```sh
fastfetch-image --size up
fastfetch-image --size down
fastfetch-image --size 30
```

Widths are limited to 6–48 columns.

### Add an image

Local file:

```sh
fastfetch-image --add ~/Pictures/my-image.png
fastfetch-image --add ~/Pictures/my-image.png my-image
```

Online image:

```sh
fastfetch-image --add https://example.com/image.jpg
```

The destination name is generated from the source filename unless `NAME` is
provided. Add a new image and then select it with `fastfetch-image`.

### Remove an image

```sh
fastfetch-image --remove
fastfetch-image --remove 3.png
```

Without an image name, `fzf` is used. A confirmation is always required. The
last remaining image cannot be removed.

## Configuration and customization

### Active files

| Path | Purpose |
| --- | --- |
| `~/.config/fastfetch/config.jsonc` | Active Fastfetch configuration. |
| `~/.config/fastfetch/current-image` | Active logo image symlink. |
| `~/.config/fastfetch/images/israrkhan-cys/` | Image collection. |
| `~/.local/bin/fastfetch-image` | Image management command. |

Because the installer uses symlinks, editing these files also edits the
repository:

- `~/.config/fastfetch/config.jsonc` → `fastfetch/config.jsonc`
- `~/.config/fastfetch/current-image` → `fastfetch/current-image`
- `~/.config/fastfetch/images/...` → `fastfetch/images/...`
- `~/.local/bin/fastfetch-image` → `scripts/fastfetch-image`

### Change the selected image

Use:

```sh
fastfetch-image
```

or:

```sh
fastfetch-image 5.jpg
```

Then commit the updated `fastfetch/current-image` symlink.

### Change the layout or colors

Edit `~/.config/fastfetch/config.jsonc`. The live configuration is the repository
file through the symlink. Validate it with:

```sh
fastfetch --config ~/.config/fastfetch/config.jsonc --logo none --pipe
```

### Update the published repository

After changing the configuration or adding images:

```sh
cd ~/dotfiles
git status
git add fastfetch scripts install.sh README.md omarchy .gitignore
git commit -m "Update Fastfetch configuration"
git push
```

The repository is already connected to `origin` and tracks `main`.

### Collection name

The script and installer use the collection directory name `israrkhan-cys`.
Renaming that directory requires updating:

- `image_dir` and the relative `current-image` target in
  `scripts/fastfetch-image`
- `images_dir` in `install.sh`
- the `current-image` symlink target

## Backups and troubleshooting

### Roll back an installation

Backups are timestamped siblings of the replaced targets:

```text
~/.config/fastfetch.bak.YYYYMMDD-HHMMSS/
~/.local/bin/fastfetch-image.bak.YYYYMMDD-HHMMSS
```

Restore them with:

```sh
rm ~/.config/fastfetch
rm ~/.local/bin/fastfetch-image
mv ~/.config/fastfetch.bak.<timestamp> ~/.config/fastfetch
mv ~/.local/bin/fastfetch-image.bak.<timestamp> ~/.local/bin/fastfetch-image
```

### Common issues

| Symptom | Check |
| --- | --- |
| `fastfetch-image: command not found` | Ensure `~/.local/bin` is on `PATH`, then open a new shell. |
| Image logo is missing or garbled | Use Ghostty/Kitty or another Kitty-graphics terminal; confirm `"type": "kitty"` in the config. |
| `magick: command not found` | Install `imagemagick`. |
| `python: command not found` | Install `python`; the script also accepts `python3`. |
| `fzf is required for interactive selection` | Install `fzf`, or pass an image name directly. |
| `fzf is required for interactive removal` | Install `fzf`, or pass an image name to `--remove`. |
| `No Fastfetch images found` | Check that `~/.config/fastfetch/images/israrkhan-cys/` exists and contains images. |
| `current-image` is missing or broken | Re-run `./install.sh`, or select an image with `fastfetch-image`. |
| `curl` errors during `--add URL` | Install `curl`, or add a local file instead. |
| Permission denied for `fastfetch-image` | Re-run `./install.sh`, or `chmod 755 ~/.local/bin/fastfetch-image`. |
| Fastfetch reports a config error | Run `fastfetch --config ~/.config/fastfetch/config.jsonc --logo none --pipe` and check the JSONC. |

The installer checks required commands and verifies the installed configuration,
the executable, and the active image. A missing image collection causes the
verification step to fail rather than leaving a silently broken setup.

## Optional Omarchy integration

The About window size is a Hyprland setting, not a Fastfetch setting. To use the
same `620 × 400` size as the original machine:

```sh
mkdir -p ~/.config/hypr
cp ~/dotfiles/omarchy/about-window.lua ~/.config/hypr/fastfetch-about.lua
```

Add this line to `~/.config/hypr/hyprland.lua` after the Omarchy defaults:

```lua
require("hypr.fastfetch-about")
```

This is optional and is **not** applied by `install.sh`. It is specific to
Omarchy's Hyprland setup. The original machine's broader glass/opacity rules and
its `ghostty-glass-sync` helper are also not included because they are
Ghostty/Hyprland appearance settings rather than Fastfetch configuration.

## Verification performed

The repository was checked against the working setup before publishing this
update:

- `fastfetch/config.jsonc` matches the working
  `~/.config/fastfetch/config.jsonc` except for the intentional portable logo
  path (`~/.config/fastfetch/current-image` instead of an absolute home path).
- All 20 collection images match the working collection byte-for-byte.
- `bash -n install.sh` and `bash -n scripts/fastfetch-image`: passed.
- `shellcheck -S error` on both scripts: no errors. One informational
  `SC2016` warning remains for a deliberate literal backtick in a `printf`
  message.
- `fastfetch --config fastfetch/config.jsonc --logo none --pipe`: exits 0 and
  produces the expected 20-line module layout.
- All 20 images were validated with `magick identify`.
- Installer tested in isolated temporary homes:
  - fresh installation;
  - existing conflicting configuration and command, with backups created;
  - repeated execution with no duplicate backups;
  - missing `current-image`, recreated automatically;
  - absolute internal `current-image` link, normalized to a relative link;
  - missing image collection, verification fails clearly.
- `fastfetch-image` tested in an isolated copy:
  - `--list`, `--help`, and direct selection;
  - `--size up`, `--size down`, explicit width, and range rejection;
  - local `--add`, duplicate rejection, invalid image rejection, and bad-name
    rejection;
  - HTTP `--add` through a local test server;
  - `--remove`, confirmation, active-image removal with automatic switch, and
    last-image protection;
  - interactive selection and removal with a stub `fzf`, including the
    current-image marker;
  - `python3` fallback when `python` is absent.

Not fully verified in this environment:

- Actual pixel rendering of the Kitty image logo in Ghostty/Kitty; the test
  environment is non-graphics.
- The real full-screen `fzf` UI; the command paths were exercised with a stub.
- Launching the Omarchy About window; the integration scripts were inspected.
- Installing into the real home directory; all installer tests used isolated
  temporary homes.
