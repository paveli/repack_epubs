# repack_epubs.sh

Repackage EPUBs into standards-compliant files so they are recognized and import cleanly in Calibre and other readers.

## Why

- Some EPUBs refuse to open or import because their internal zip order is wrong (the tiny `mimetype` file must be first and uncompressed).
- On macOS, the Books app can store a book as a **folder** that looks like a file; other apps expect a single `.epub` file.

## Quick guide (macOS)

1. Download: On GitHub click **Code → Download ZIP**, double-click it (usually ends up in `~/Downloads/repack_epubs`).
2. Open Terminal: Press `Cmd + Space`, type “Terminal”, press Enter.
3. Go to the folder: `cd ~/Downloads/repack_epubs`
4. Make a workspace (keeps originals safe): `mkdir -p tmp/my-epubs`
5. Copy your Books app files: `cp ~/Library/Mobile\ Documents/iCloud\~com\~apple\~iBooks/Documents/*.epub tmp/my-epubs/`
6. Run the script: `bash repack_epubs.sh tmp/my-epubs`
7. Get results: `tmp/my-epubs/fixed_epubs/` (repaired) and `tmp/my-epubs/original_epubs/` (backups). Import from `fixed_epubs/`.

## What it does

- Takes your books (either `.epub` files or the “folder” kind) and rebuilds them correctly.
- Puts the original copies in `original_epubs/` as a safety backup.
- Puts the repaired copies (same names) in `fixed_epubs/`.

## macOS Books tip

If you added your own books to the Books app (not bought from Apple), copy them first from:

```
~/Library/Mobile\ Documents/iCloud\~com\~apple\~iBooks/Documents/
```

into a working folder, then run the script on that folder.

## Requirements

- `bash`
- `zip`
- `unzip`

## Notes

- Exits non-zero if `zip`/`unzip` are missing or no EPUBs are found.
- Originals stay untouched in `original_epubs/` so you can restore them anytime.
