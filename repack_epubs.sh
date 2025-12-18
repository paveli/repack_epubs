#!/usr/bin/env bash

set -euo pipefail

# Parse flags and optional target directory.
verbose=0
target_dir="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--verbose)
      verbose=1
      ;;
    -h|--help)
      echo "Usage: bash repack_epubs.sh [-v|--verbose] [path]" >&2
      exit 0
      ;;
    *)
      target_dir="$1"
      ;;
  esac
  shift
done

cd "$target_dir"

# Log only when verbose is enabled.
log() { echo "$@"; }
vlog() {
  if [ "$verbose" -eq 1 ]; then
    log "$@"
  fi
  return 0
}

# Ensure required tools are present.
if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip is required but not installed" >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "zip is required but not installed" >&2
  exit 1
fi

# Gather EPUB-like items (case-insensitive) in the target directory.
shopt -s nullglob nocaseglob
epubs=(*.epub)
shopt -u nocaseglob

if [ ${#epubs[@]} -eq 0 ]; then
  echo "No .epub files found in $(pwd)" >&2
  exit 1
fi

log "Processing ${#epubs[@]} EPUB(s) in $(pwd)..."

processed=0
failed=0

orig_dir="original_epubs"
fixed_dir="fixed_epubs"

mkdir -p "$orig_dir" "$fixed_dir"

# Repackage each EPUB or EPUB folder.
for f in "${epubs[@]}"; do
  base="${f%.*}"
  out="$fixed_dir/$f"

  vlog "Repacking '$f'..."

  if [ -e "$out" ]; then
    if [ -e "$f" ]; then
      mv -- "$f" "$orig_dir/" || echo "Warning: output exists and failed to archive original '$f'" >&2
    fi
    vlog "Skipping '$f' because '$out' already exists"
    continue
  fi

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  if [ -d "$f" ]; then
    # Already an extracted EPUB folder; copy its contents.
    if ! cp -R -- "$f"/ "$tmpdir/"; then
      echo "Failed to copy directory '$f'" >&2
      failed=$((failed + 1))
      rm -rf "$tmpdir"
      trap - EXIT
      continue
    fi
  else
    # Standard EPUB file; unzip after copying in.
    cp -- "$f" "$tmpdir/$f"

    if ! (cd "$tmpdir" && mv "$f" "$base.zip" && unzip -qq "$base.zip" && rm "$base.zip"); then
      echo "Failed to unzip '$f'" >&2
      failed=$((failed + 1))
      rm -rf "$tmpdir"
      trap - EXIT
      continue
    fi
  fi

  # Guarantee required mimetype file exists.
  if [ ! -f "$tmpdir/mimetype" ]; then
    printf '%s' "application/epub+zip" > "$tmpdir/mimetype"
  fi

  # Create a standards-compliant EPUB: mimetype first, uncompressed; rest follows.
  if ! (cd "$tmpdir" && zip -q -X0 "$f" mimetype && zip -q -Xr9D "$f" . -x "$f" mimetype); then
    echo "Failed to repackage '$f'" >&2
    failed=$((failed + 1))
    rm -rf "$tmpdir"
    trap - EXIT
    continue
  fi

  mv -- "$tmpdir/$f" "$out"
  rm -rf "$tmpdir"
  trap - EXIT

  if ! mv -- "$f" "$orig_dir/"; then
    echo "Warning: created fixed file but failed to archive original '$f'" >&2
  fi

  vlog "Created '$out'"
  processed=$((processed + 1))
done

echo "Finished. Processed: $processed. Failed: $failed."
