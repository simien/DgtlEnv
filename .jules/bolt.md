## 2024-05-23 - [Optimizing Shell Script Text Processing]
**Learning:** Shell scripts often suffer from "death by a thousand cuts" (processes) when parsing text. Using a pipeline of `grep | awk | sed` for each variable assignment is inefficient because it spawns multiple subshells and processes for every single value.
**Action:** When extracting multiple values from a single command output (like `vm_stat`), parse the entire output in a single pass using `awk` or `read` loops. This dramatically reduces process creation overhead (e.g., from ~15 processes to ~3).

## 2024-05-23 - [Handling macOS specific tools in Linux environment]
**Learning:** Tools like `vm_stat` and `sysctl` (macOS specific keys) are not available on Linux. When optimizing scripts for a specific OS while running in a different environment, use reproduction scripts with mocked output to verify logic correctness without needing the actual tool.
**Action:** Create temporary "repro" scripts that mock the output of the missing command to verify the parsing logic before applying changes to the main script.
