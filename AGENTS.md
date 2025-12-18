# Repository Guidelines

## Project Structure & Organization
- `repack_epubs.sh`: Single entry-point script that repackages EPUBs so `mimetype` is first and uncompressed.
- `README.md`: Usage overview and prerequisites.
- `original_epubs/`, `fixed_epubs/`, `tmp/`: Working folders used during processing; keep backups and outputs out of version control.

## Build, Test, and Development Commands
- `bash repack_epubs.sh [path]`: Repackage `.epub` files in the target directory (defaults to current). Creates `original_epubs/` backups and `fixed_epubs/` outputs.
- `bash repack_epubs.sh -v [path]`: Verbose mode with per-file progress.
- Manual smoke test: copy a sample `.epub` (or an EPUB folder) into `tmp/test_run/`, run the script there, and confirm both `fixed_epubs/` and `original_epubs/` contain the expected file.

## Coding Style & Naming Conventions
- Language: POSIX-friendly Bash with `set -euo pipefail` and `shopt` for glob handling.
- Functions: use descriptive, lowercase names (`log`, `vlog`) and prefer guard checks for tools/inputs.
- Flags: keep short/long forms aligned (`-v|--verbose`, `-h|--help`).
- I/O: write logs to stdout; send errors to stderr; avoid silent failures.

## Testing Guidelines
- No automated test suite; rely on manual smoke tests per change.
- When modifying packaging logic, validate with: a normal `.epub`, an EPUB stored as a folder, and a case-insensitive filename to ensure glob handling works.
- Confirm `mimetype` is first and uncompressed in the rebuilt archive (e.g., `zipinfo -1 fixed_epubs/book.epub | head -n 1`).

## Commit & Pull Request Guidelines
- Commit messages: imperative mood, concise scope (e.g., "Add verbose logging"), grouping related Bash changes together.
- Pull requests: include a brief summary of the change, steps used to test (commands run and sample files), and any edge cases considered (existing output, missing tools, empty directory).

## Security & Operations Tips
- Script performs no network calls or elevated privileges; it operates within the target directory. Keep backups (`original_epubs/`) intact for recovery.
- Avoid running on live libraries directly; work on copies in a temporary directory to prevent accidental overwrites.
