# repack_epubs.sh

Repackage EPUBs into standards-compliant files so they are recognized and import cleanly in Calibre and other readers.

## Why

- Some EPUBs refuse to open or import because their internal zip order is wrong (the tiny `mimetype` file must be first and uncompressed).
- On macOS, the Books app can store a book as a **folder** that looks like a file; other apps expect a single `.epub` file.

## Quick start

```bash
# default: current directory
bash repack_epubs.sh

# or target a specific folder
bash repack_epubs.sh /path/to/epubs

# show per-file progress
bash repack_epubs.sh -v /path/to/epubs
```

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
