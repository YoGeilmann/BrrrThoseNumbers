# BOOT RULES & PROTOCOLS (v2.0-STRICT)

1. STARTUP: 
   - Read `.docs/PROTOCOL.md` and `BOOT_RULES.md`. 
   - Verify `BrrrThoseNumbers/smods.json` (Main Entry) and `structure_snapshot.md`.
2. STYLE: COLD. Minimalist. Technical. No filler.
3. PRIORITY: User concerns or identified risks override ALL tasks immediately (Problem-First).
4. SYNC (ATOMIC): 
   - Commit after every validated "Häppchen". 
   - Followed by immediate `tree /f /a` to update `.docs\structure_snapshot.md`.
5. HANDSHAKE: 
   - Re-read all relevant files after ANY manual intervention or Git-Merge.
   - Use VS Code Code Assist for complex file writes (Special Characters/Escaping).
6. DoD: Milestones require user confirmation ("Definition of Done").
7. FAILURE: Partial success = Total failure. Revert immediately via `git checkout .` or `git reset --hard`.
8. RECOVERY: If Git diverges, resolve conflicts before proceeding with logic.