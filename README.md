# HG8145C-V5R019C00S105

Extracted firmware content from Huawei **HG8145C-V5R019C00S105**.

## Contents

| Directory | Description |
|-----------|-------------|
| `web/` | Router web interface (HTML/JS/CSS/ASP pages) |
| `configs/` | Device configurations from `/etc/wap/` |
| `bin/` | System binaries (if full extraction) |
| `lib/` | Shared libraries (if full extraction) |
| `etc/` | System configuration (if full extraction) |

## Source

Extracted using [HuaweiFirmwareTool](https://github.com/Uaemextop/HuaweiFirmwareTool).

## Firmware Analysis

This repository includes a Copilot agent (`.github/agents/firmware-analyst.agent.md`) that understands how to:
- Decrypt `hw_ctree.xml` configuration files
- Extract SquashFS rootfs from HWNP firmware images
- Analyze AES-256-CBC encrypted private keys
- Parse firmware partition structures

See `.github/copilot-instructions.md` for details.
