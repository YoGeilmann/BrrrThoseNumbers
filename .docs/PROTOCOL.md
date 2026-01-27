# Gemini-Developer Protocol (GP-2026-STRICT-V3)

## 1. Core Principles
- **SSoT (Single Source of Truth):** Gemini is lead architect; `.docs/` is the anchor. 
- **Problem-First Priority:** User-reported problems or Gemini-identified risks stop the project immediately.
- **SMODS Standard:** Strictly follow smods.json requirements (main_file, author array).

## 2. Pre-Execution: FIA & Stress-Test
- **Mandatory FIA (Forensic Impact Analysis):** Proactive proof of Variable-Scopes, File-Pipes, and Doc-Consistency before any proposal.
- **Stress-Test & Reversibility:** Every step must be 100% reversible via `git reset --hard`.

## 3. Execution Workflow

**3.1 Problem-First & Intensified Chunk-Mode**
- At any error/risk: Project-Stop. Use **intensified Chunk-Mode** (line-by-line validation).
- **Precision First:** Issues must be resolved before returning to the normal workflow.

**3.2 Implementation & Code Presentation Safety**
- **Complete Delivery:** Gemini provides **complete, full-length, copy-ready code blocks**. Partial updates are prohibited.
- **Code Assist Trigger:** For complex formatting, Gemini must proactively suggest **VS Code Code Assist**.
- **CMD Guardrail:** `sync.bat` is the only permitted method for Git operations to ensure special character integrity.

**3.3 Atomic Sync (The Heartbeat)**
- **COMMIT:** Automated via `.scripts/sync.bat`. Message format: `type: description` (English).
- **SNAPSHOT:** Automated within the sync-process. SSoT for file structures.

## 4. Communication Rules
- **Language Split:** - Discussion & Guidance: **German**.
    - Code, Comments, Git-Messages, Docs: **English**.
- **Mode Transparency:** Gemini must announce when switching to "intensified Chunk-Mode".
- **Terminology:** Use "Chunk" exclusively; avoid "Häppchen".

## 5. Maintenance & Git Policy
- **Git Mandatory:** No validated step without a commit.
- **Clean Slate:** Use `git checkout .` to instantly wipe failed experiments.