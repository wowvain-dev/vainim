#!/usr/bin/env bash
set -euo pipefail

config_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_source_real="$(realpath "$config_source")"

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
nvim_target="$config_home/nvim"

echo "vainim setup"
echo "  Source : $config_source_real"
echo "  Target : $nvim_target"
echo

mkdir -p "$config_home"

if [[ -L "$nvim_target" ]]; then
  existing_target="$(realpath "$nvim_target")"
  if [[ "$existing_target" == "$config_source_real" ]]; then
    echo "[OK] Symlink already exists and points to the correct location."
    exit 0
  fi

  echo "[!] Symlink already exists but points to: $existing_target"
  read -r -p "    Replace it? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    exit 1
  fi
  rm "$nvim_target"
elif [[ -e "$nvim_target" ]]; then
  echo "[!] $nvim_target exists but is NOT a symlink."
  echo "    Backup its contents first, then remove it and re-run."
  exit 1
fi

ln -s "$config_source_real" "$nvim_target"

if [[ -L "$nvim_target" ]]; then
  echo "[OK] Symlink created successfully!"
  echo
  echo "Next steps:"
  echo "  1. Open Neovim: nvim"
  echo "  2. lazy.nvim will auto-install on first launch"
  echo "  3. Mason will install LSP servers automatically"
  echo "  4. Restart nvim after initial install"
  echo
  echo "Quick config locations:"
  echo "  Theme    : lua/plugins/colorscheme.lua  (change ACTIVE_THEME)"
  echo "  LSP      : lua/lsp/servers.lua          (add/remove languages)"
  echo "  Keymaps  : lua/config/keymaps.lua"
  echo "  Options  : lua/config/options.lua"
else
  echo "[FAIL] Could not create symlink."
  exit 1
fi
