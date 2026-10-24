#!/usr/bin/env bash
# Install the portable Fastfetch setup into the current user's home directory.
#
# The installer links the repository's fastfetch directory and the
# fastfetch-image command into place. Existing files are moved aside, never
# deleted. Running it again is a no-op once the links are in place.
set -euo pipefail

: "${HOME:?HOME must be set}"

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FASTFETCH_SOURCE="$REPO_DIR/fastfetch"
SCRIPT_SOURCE="$REPO_DIR/scripts/fastfetch-image"

FASTFETCH_TARGET="$HOME/.config/fastfetch"
BIN_DIR="$HOME/.local/bin"
SCRIPT_TARGET="$BIN_DIR/fastfetch-image"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '%s\n' "$*"; }
warn() { printf 'Warning: %s\n' "$*" >&2; }

link_into_place() {
    local source="$1"
    local target="$2"
    local label="$3"

    if [[ -L "$target" ]] &&
        [[ "$(readlink -f -- "$target" 2>/dev/null || true)" == "$(readlink -f -- "$source")" ]]; then
        info "$label is already linked to the repository."
        return 0
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        local backup="${target}.bak.${STAMP}"
        local suffix=1
        while [[ -e "$backup" || -L "$backup" ]]; do
            backup="${target}.bak.${STAMP}.${suffix}"
            suffix=$((suffix + 1))
        done
        mv -- "$target" "$backup"
        info "Backed up $target -> $backup"
    fi

    mkdir -p -- "$(dirname -- "$target")"
    local relative
    relative="$(realpath --relative-to="$(dirname -- "$target")" "$source")"
    ln -s -- "$relative" "$target"
    info "Linked $target -> $relative"
}

ensure_current_image() {
    local current="$FASTFETCH_SOURCE/current-image"
    local images_dir="$FASTFETCH_SOURCE/images/israrkhan-cys"

    [[ -e "$current" ]] && return 0

    local first
    first="$(find "$images_dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) \
        -printf '%f\n' 2>/dev/null | sort -V | head -n 1 || true)"
    if [[ -n "$first" ]]; then
        ln -sfn -- "images/israrkhan-cys/$first" "$current"
        info "Created default current-image -> images/israrkhan-cys/$first"
    else
        warn "No images found in $images_dir; fastfetch will have no logo."
    fi
}

check_dependencies() {
    local missing_required=()
    local missing_optional=()
    local command

    for command in fastfetch magick python awk; do
        command -v "$command" >/dev/null 2>&1 || missing_required+=("$command")
    done
    for command in fzf curl; do
        command -v "$command" >/dev/null 2>&1 || missing_optional+=("$command")
    done

    if ((${#missing_required[@]})); then
        warn "Missing required command(s): ${missing_required[*]}"
        warn "On Omarchy/Arch: sudo pacman -S --needed fastfetch imagemagick python"
    fi
    if ((${#missing_optional[@]})); then
        warn "Missing optional command(s): ${missing_optional[*]}"
        warn "fzf is used for interactive image selection/removal; curl is used by 'fastfetch-image --add URL'."
        warn "On Omarchy/Arch: sudo pacman -S --needed fzf curl"
    fi
}

[[ -d "$FASTFETCH_SOURCE" ]] || {
    printf 'Error: %s does not exist.\n' "$FASTFETCH_SOURCE" >&2
    exit 1
}
[[ -f "$SCRIPT_SOURCE" ]] || {
    printf 'Error: %s does not exist.\n' "$SCRIPT_SOURCE" >&2
    exit 1
}

info "Installing Fastfetch dotfiles from $REPO_DIR"

ensure_current_image
link_into_place "$FASTFETCH_SOURCE" "$FASTFETCH_TARGET" "Fastfetch configuration"
link_into_place "$SCRIPT_SOURCE" "$SCRIPT_TARGET" "fastfetch-image command"

chmod 755 "$SCRIPT_SOURCE"
chmod 755 "$FASTFETCH_SOURCE" "$FASTFETCH_SOURCE/images" \
    "$FASTFETCH_SOURCE/images/israrkhan-cys" 2>/dev/null || true

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "$BIN_DIR is not on PATH in this shell."
    warn "Omarchy adds it automatically; otherwise add: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

check_dependencies

info ""
info "Done. Try: fastfetch"
info "Image manager: fastfetch-image --help"
