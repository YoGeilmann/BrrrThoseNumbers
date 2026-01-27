# BOOT RULES & PROTOCOLS (v2.1-STRICT)

1. STARTUP:
   - Read `.docs/PROTOCOL.md` and `BOOT_RULES.md`.
   - Verify `BrrrDebugBridge/smods.json` (Current Focus) and `structure_snapshot.md`.
2. STYLE: COLD. Minimalist. Technical. No filler.
3. PRIORITY: User concerns or identified risks override ALL tasks immediately (Problem-First).
4. SYNC (ATOMIC):
   - Commit after every validated "Haeppchen".
   - Followed by immediate `tree /f /a` to update `.docs\structure_snapshot.md`.
5. HANDSHAKE:
   - Re-read all relevant files after ANY manual intervention or Git-Merge.
   - Use VS Code Code Assist for complex file writes (Special Characters/Escaping).
6. DoD: Milestones require user confirmation ("Definition of Done").
7. FAILURE: Partial success = Total failure. Revert immediately via `git checkout .` or `git reset --hard`.
8. RECOVERY: If Git diverges, resolve conflicts before proceeding with logic.
9. DEBUG STACK: Automated stress tests require both DebugPlus and DebugPlusPlus to be active.
10. LAUNCH: Intro bypass is permitted via Global Lua Override (bridge_logic.lua). 
    To prevent audio buffer issues, the override must ensure G.SETTINGS.skip_splash is set 
    at the earliest possible execution point.