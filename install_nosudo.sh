#!/usr/bin/env bash
#
# setup.sh — no-sudo install of tmux, fish, vim tooling into ~/.local/bin
# NOTE: vim is assumed to exist
#
# Installs: tmux (AppImage), fish, fd, bat, fzf, TPM, fisher + fish plugins
# Copies dotfiles from this script's directory into $HOME (backing up existing).
#
# Usage: ./setup.sh [--force] [--skip-configs] [--skip-plugins]

set -Eeuo pipefail

# ---------------------------------------------------------------- pinned versions
FISH_TAG="4.9.3"
TMUX_TAG="3.5a"
FD_TAG="v10.5.0"
BAT_TAG="v0.26.1"

FISH_REPO="fish-shell/fish-shell"
TMUX_REPO="nelsonenzo/tmux-appimage"
FD_REPO="sharkdp/fd"
BAT_REPO="sharkdp/bat"

# ---------------------------------------------------------------- globals
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
STAMP="$(date +%Y%m%d%H%M%S)"
TMP_DIR=""
FORCE=0
SKIP_CONFIGS=0
SKIP_PLUGINS=0

# ---------------------------------------------------------------- output helpers
c_reset=$'\033[0m'; c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'
c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'; c_dim=$'\033[2m'

step()     { printf '\n%s==>%s %s\n' "$c_blue"   "$c_reset" "$*"; }
sub_step() { printf '%s  ->%s %s\n'  "$c_dim"    "$c_reset" "$*"; }
ok()       { printf '%s  ok%s %s\n'  "$c_green"  "$c_reset" "$*"; }
warn()     { printf '%s  !!%s %s\n'  "$c_yellow" "$c_reset" "$*" >&2; }
die()      { trap - ERR; printf '\n%serror:%s %s\n' "$c_red" "$c_reset" "$*" >&2; exit 1; }

cleanup() { [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]] && rm -rf -- "$TMP_DIR"; }
trap cleanup EXIT
trap 'die "failed at line $LINENO"' ERR

# ---------------------------------------------------------------- arg parsing
while (($#)); do
  case "$1" in
    --force)        FORCE=1 ;;
    --skip-configs) SKIP_CONFIGS=1 ;;
    --skip-plugins) SKIP_PLUGINS=1 ;;
    -h|--help)      sed -n '2,10p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *)              die "unknown option: $1" ;;
  esac
  shift
done

# ---------------------------------------------------------------- preflight
preflight() {
  step "Preflight checks"

  # --- PATH check: hard stop if ~/.local/bin is not on PATH
  case ":${PATH}:" in
    *":${BIN_DIR}:"*) ok "$BIN_DIR is on PATH" ;;
    *)
      mkdir -p "$BIN_DIR"
      if [[ ! -f "$BIN_DIR/env" ]]; then
        cat >"$BIN_DIR/env" <<'EOF'
#!/bin/sh
# Prepend ~/.local/bin to PATH (idempotent).
case ":${PATH}:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
        chmod 0644 "$BIN_DIR/env"
        sub_step "created $BIN_DIR/env"
      fi
      cat >&2 <<EOF

${c_red}$BIN_DIR is not on your PATH.${c_reset}

Add this line to your ~/.bashrc, then open a new shell and re-run this script:

    . "\$HOME/.local/bin/env"

(or, equivalently:  export PATH="\$HOME/.local/bin:\$PATH")
EOF
      trap - ERR
      exit 1
      ;;
  esac

  # --- required tools
  local missing=()
  for cmd in curl git tar grep sed unzip wget vi; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  ((${#missing[@]})) && die "missing required command(s): ${missing[*]}"

  # fish/tarballs ship as .tar.xz
  tar --help 2>/dev/null | grep -q -- '--xz' || command -v xz >/dev/null 2>&1 \
    || die "no xz support in tar and no 'xz' binary; cannot extract fish"

  # --- architecture
  case "$(uname -m)" in
    x86_64|amd64)  ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) die "unsupported architecture: $(uname -m)" ;;
  esac
  ok "architecture: $ARCH"

  [[ "$(uname -s)" == "Linux" ]] || die "this script targets Linux only"

  TMP_DIR="$(mktemp -d)"
  ok "workdir: $TMP_DIR"
}

# ---------------------------------------------------------------- helpers
# Resolve a release asset download URL for a pinned tag.
#
# Primary source is the plain-HTML expanded_assets endpoint, which is NOT
# rate limited. The JSON API is only a fallback: unauthenticated it allows
# 60 requests/hour per source IP, which is easy to exhaust behind corporate
# NAT. Returns 1 on failure so the caller (in a command substitution) can
# die in the parent shell rather than a subshell.
gh_asset_url() {
  local repo="$1" tag="$2" pattern="$3" path url

  path="$(curl -fsSL --retry 3 --retry-delay 2 --proto '=https' --tlsv1.2 \
        "https://github.com/${repo}/releases/expanded_assets/${tag}" 2>/dev/null \
      | grep -o 'href="[^"]*/releases/download/[^"]*"' \
      | cut -d'"' -f2 \
      | grep -Ei -- "$pattern" \
      | head -n1)" || true
  if [[ -n "$path" ]]; then
    printf 'https://github.com%s' "$path"
    return 0
  fi

  url="$(curl -fsSL --retry 3 --retry-delay 2 --proto '=https' --tlsv1.2 \
        -H 'Accept: application/vnd.github+json' \
        "https://api.github.com/repos/${repo}/releases/tags/${tag}" 2>/dev/null \
      | grep -o '"browser_download_url"[[:space:]]*:[[:space:]]*"[^"]*"' \
      | cut -d'"' -f4 \
      | grep -Ei -- "$pattern" \
      | head -n1)" || true
  if [[ -n "$url" ]]; then
    printf '%s' "$url"
    return 0
  fi

  return 1
}

fetch() {  # fetch <url> <dest-file>
  curl -fsSL --retry 3 --retry-delay 2 --proto '=https' --tlsv1.2 -o "$2" -- "$1"
}

# Install a single executable into BIN_DIR with correct perms.
install_bin() {  # install_bin <src> <name>
  install -m 0755 -D -- "$1" "$BIN_DIR/$2"
  ok "installed $2 -> $BIN_DIR/$2"
}

# Skip a component if its binary already exists and --force was not given.
have_bin() {  # have_bin <name>
  if [[ $FORCE -eq 0 && -x "$BIN_DIR/$1" ]]; then
    ok "$1 already present (use --force to reinstall)"
    return 0
  fi
  return 1
}

# Back up an existing path, then return so the caller can write fresh.
backup_path() {  # backup_path <path>
  [[ -e "$1" || -L "$1" ]] || return 0
  mv -- "$1" "$1.bak.$STAMP"
  sub_step "backed up $(basename -- "$1") -> $(basename -- "$1").bak.$STAMP"
}

# Copy a repo-relative dotfile/dir into $HOME, backing up whatever is there.
place() {  # place <relative-path>
  local src="$SCRIPT_DIR/$1" dst="$HOME/$1"
  if [[ ! -e "$src" ]]; then
    warn "skipping $1 (not found in $SCRIPT_DIR)"
    return 0
  fi
  backup_path "$dst"
  mkdir -p -- "$(dirname -- "$dst")"
  cp -a -- "$src" "$dst"
  ok "placed $1"
}

# ---------------------------------------------------------------- installers
install_tmux() {
  step "tmux ${TMUX_TAG} (AppImage)"
  have_bin tmux && return 0
  local url
  url="$(gh_asset_url "$TMUX_REPO" "$TMUX_TAG" 'tmux.*\.appimage$')"
  sub_step "$url"
  fetch "$url" "$TMP_DIR/tmux.appimage"
  install_bin "$TMP_DIR/tmux.appimage" "tmux.appimage"
  # Real executable on PATH, not an alias: tmux re-invokes itself from
  # non-interactive subshells (status bar, TPM, pane splits) where aliases
  # do not exist.
  ln -sfn "$BIN_DIR/tmux.appimage" "$BIN_DIR/tmux"
  ok "symlinked tmux -> tmux.appimage"
}

install_fish() {
  step "fish ${FISH_TAG}"
  have_bin fish && return 0
  local url dir
  url="$(gh_asset_url "$FISH_REPO" "$FISH_TAG" "linux.*${ARCH}.*\.tar\.xz$")"
  sub_step "$url"
  fetch "$url" "$TMP_DIR/fish.tar.xz"
  dir="$TMP_DIR/fish"; mkdir -p "$dir"
  tar -xJf "$TMP_DIR/fish.tar.xz" -C "$dir"
  local found=0 f
  # Standalone build ships fish plus its helper binaries.
  for name in fish fish_indent fish_key_reader; do
    f="$(find "$dir" -type f -name "$name" -perm -u+x -print -quit)"
    if [[ -n "$f" ]]; then install_bin "$f" "$name"; found=1; fi
  done
  ((found)) || die "no fish binaries found in extracted archive"
}

install_sharkdp() {  # install_sharkdp <repo> <tag> <binary-name>
  local repo="$1" tag="$2" name="$3" url dir f
  step "${name} ${tag}"
  have_bin "$name" && return 0
  # musl builds are statically linked: no glibc version coupling.
  url="$(gh_asset_url "$repo" "$tag" "${ARCH}-unknown-linux-musl\.tar\.gz$")"
  sub_step "$url"
  fetch "$url" "$TMP_DIR/$name.tar.gz"
  dir="$TMP_DIR/$name.d"; mkdir -p "$dir"
  tar -xzf "$TMP_DIR/$name.tar.gz" -C "$dir"
  f="$(find "$dir" -type f -name "$name" -perm -u+x -print -quit)"
  [[ -n "$f" ]] || die "$name binary not found in archive"
  install_bin "$f" "$name"
}

install_fzf() {
  step "fzf"
  if [[ $FORCE -eq 0 && -x "$BIN_DIR/fzf" ]]; then
    ok "fzf already present (use --force to reinstall)"
    return 0
  fi
  if [[ -d "$HOME/.fzf/.git" ]]; then
    sub_step "updating existing ~/.fzf"
    git -C "$HOME/.fzf" fetch --depth 1 origin master -q
    git -C "$HOME/.fzf" reset --hard origin/master -q
  else
    backup_path "$HOME/.fzf"
    git clone --depth 1 -q https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  # --bin only: fzf.fish provides the fish keybindings, so no rc mangling.
  "$HOME/.fzf/install" --bin >/dev/null
  install_bin "$HOME/.fzf/bin/fzf" "fzf"
}

# ---------------------------------------------------------------- configs
place_configs() {
  step "Dotfiles"

  sub_step ".inputrc"
  place ".inputrc"

  sub_step "vim"
  place ".vimrc"
  place ".vim"

  sub_step "tmux"
  place ".tmux.conf"
  place ".tmux"

  sub_step "fish"
  place ".config/fish/config.fish"

  # TPM — tmux plugin manager
  local tpm="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm/.git" ]]; then
    sub_step "updating tpm"
    git -C "$tpm" pull -q --ff-only || warn "tpm update failed; leaving as-is"
  else
    backup_path "$tpm"
    mkdir -p -- "$(dirname -- "$tpm")"
    git clone -q https://github.com/tmux-plugins/tpm "$tpm"
    ok "cloned tpm"
  fi
}

# ---------------------------------------------------------------- fish plugins
install_fish_plugins() {
  step "fisher + fish plugins"

  # fzf.fish expects fzf, fd and bat to already resolve on PATH.
  local missing=()
  for cmd in fzf fd bat; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  ((${#missing[@]})) && die "fish plugins need these on PATH first: ${missing[*]}"

  # Bootstrap fisher, then install plugins, all inside one fish session.
  # --no-config skips config.fish/conf.d during bootstrap: the user's config
  # may call functions (fzf_configure_bindings, tide, ...) that the plugins
  # have not provided yet. Installs still land in ~/.config/fish as normal.
  fish --no-config -c '
    if not functions -q fisher
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
      and fisher install jorgebucaran/fisher
    end
    for p in jorgebucaran/fisher PatrickF1/fzf.fish IlanCosman/tide edc/bass
      fisher install $p; or exit 1
    end
  ' || die "fisher/plugin install failed"

  ok "fisher, fzf.fish, tide, bass installed"
}

# ---------------------------------------------------------------- summary
summary() {
  step "Done"
  printf '  binaries in %s:\n' "$BIN_DIR"
  for b in tmux fish fd bat fzf; do
    if command -v "$b" >/dev/null 2>&1; then
      printf '    %s%-6s%s %s\n' "$c_green" "$b" "$c_reset" "$(command -v "$b")"
    else
      printf '    %s%-6s%s not found\n' "$c_yellow" "$b" "$c_reset"
    fi
  done
  cat <<EOF

  Next steps:
    - tmux plugins:  start tmux, then press <prefix> + I to let TPM fetch them
    - fish prompt:   run 'tide configure' inside fish
    - fish by default without chsh, add to the END of ~/.bashrc:

        [[ \$- == *i* && -z "\$FISH_STARTED" ]] && FISH_STARTED=1 exec fish

EOF
}

# ---------------------------------------------------------------- main
main() {
  preflight
  export PATH="$BIN_DIR:$PATH"

  install_tmux
  install_fish
  install_sharkdp "$FD_REPO"  "$FD_TAG"  "fd"
  install_sharkdp "$BAT_REPO" "$BAT_TAG" "bat"
  install_fzf

  # Plugins first: config.fish references functions the plugins provide, so
  # placing it beforehand makes every later fish invocation spew errors.
  ((SKIP_PLUGINS)) || install_fish_plugins
  ((SKIP_CONFIGS)) || place_configs

  summary
}

main "$@"