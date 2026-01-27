# PROJECT SYNC VERIFIED: 2024-05-22T10:45:01Z

# BrrrThoseNumbers & BrrrDebugBridge

## 🏗 Modular Architecture
Dual-mod environment separating production code from development tools.

### 1. BrrrThoseNumbers (Core Mod)
- **Framework:** SMODS.
- **Independence:** Standalone mod, no debug dependencies.

### 2. BrrrDebugBridge (Dev Tool)
- **Framework:** SMODS + lovely-injector + DebugPlus + DebugPlusPlus (ID: dpp).
- **Role:** Technical bridge to expose core internal states via global hooks or lovely-patches without polluting production logic.

## 🛠 Prerequisites & Dependencies
- **Steamodded (SMODS):** Mandatory base.
- **lovely-injector:** Required for patching/DebugPlus.
- **DebugPlus + DebugPlusPlus (ID: dpp):** Required for real-time console debugging (Bridge users only).
- **luac54.exe:** Internal tool in `.tools/` for syntax validation.

## 🚦 Automation & ATOMIC SYNC Workflow
Governed by the GP-2026 Protocol. We enforce an **Atomic Sync** policy: No code is committed without validation and a structural snapshot.

### Step 1: Deployment & Launch (`sync.bat`)
- **Validate:** Runs `.tools\luac54.exe -p` on all Lua files.
- **Mirror:** Uses `robocopy /MIR` to sync to Balatro Mods folder.
- **Launch:** Automatically starts `Balatro.exe`.

### Step 2: Persistence & Snapshots (`checkpoint.bat`)
- **Commit:** Automated timestamped git commit.
- **Snapshot:** Refreshes `.docs\structure_snapshot.md` via `tree /f /a`.

## 🛡 Safety & Recovery
- **Failure Policy:** Partial success = Total failure. If `sync.bat` fails, no deployment occurs.
- **Instant Revert:** In case of game-breaking bugs, use `git checkout .` or `git reset --hard` to return to the last stable Checkpoint.
- **Integrity Check:** `luac54` acts as the primary gatekeeper against syntax-related crashes.
- **Reversibility:** Every Atomic Sync is a 'Safe Point'. All checkpoints must be stress-tested for clean reverts.
- **Undo Reliability:** Stress tests verify that reverting to a previous checkpoint leaves no artifacts in the workspace or the Balatro environment.

## ⚖️ Governance & Protocols
- **Primary Directive:** Adherence to the GP-2026 Protocol.
- **AI-Collaboration Standard (Häppchen-Modus):** No code injection without joint validation of technical debt and side effects.
- **Problem-First:** User-identified risks override project goals immediately.

## 💻 Commands
- Deploy & Test: `.scripts/sync.bat`
- Atomic Checkpoint: `.scripts/checkpoint.bat`

## Current Status: Online and Connected to YoGeilmann.