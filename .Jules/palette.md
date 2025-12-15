## 2025-12-14 - [Bash Script UX]
**Learning:** CLI tools in this repo are heavily macOS-dependent but lack compatibility checks, leading to confusing errors on other systems.
**Action:** When working on shell scripts, always add `command -v` checks or OS detection to provide clear feedback instead of raw errors.

## 2025-12-15 - [CLI Header Retention]
**Learning:** Standard `sort` commands in pipelines often swallow or displace CSV/Table headers, making output unreadable.
**Action:** Use `awk 'NR==1 {print; next} {print | "sort ..."}'` pattern to reliably preserve headers in sorted CLI output.
