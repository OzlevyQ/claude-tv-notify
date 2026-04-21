# Install prompt

Copy the block below and paste it into a fresh `claude` session. Claude Code will walk through the whole setup — creating the hook script, wiring it into `settings.json`, and sending a smoke test to your TV.

Before you paste, make sure **TvOverlay** is already installed and running on your TV (see the main [README](README.md#1-install-tvoverlay-on-the-tv)), and note the IP shown under the QR code on its main screen. The prompt will ask you for it.

---

```
You are helping me install the `claude-tv-notify` Stop hook from https://github.com/OzlevyQ/claude-tv-notify so that every time you finish replying, a notification pops up on my Android TV.

Prerequisites I've already done:
- Installed the TvOverlay app on an Android/Google TV.
- Granted TvOverlay the "Display over other apps" permission.
- I will give you the TV's IP when you ask.

Please do all of the following without asking me to confirm every step — go ahead and execute:

1. Ask me for the TV IP shown in the TvOverlay app ("You can also connect manually" section). Don't proceed until I give it.

2. Run a smoke test: POST to `http://<IP>:5001/notify` with a small JSON payload ({"title":"Smoke test","message":"If you see this, the path works.","duration":6,"corner":"top_end"}). Show me the HTTP response. If it's not a success, stop and help me debug (likely: wrong IP, TV asleep, firewall, not on same Wi-Fi) — don't continue to step 3 until the smoke test works.

3. Create `~/.claude/hooks/` if it doesn't exist. Fetch `hooks/tv-notify.sh` from https://raw.githubusercontent.com/OzlevyQ/claude-tv-notify/main/hooks/tv-notify.sh and write it to `~/.claude/hooks/tv-notify.sh`. Replace the placeholder `YOUR_TV_IP` inside that file with the IP I gave you. Make the file executable.

4. Merge a `Stop` hook entry into `~/.claude/settings.json` using an absolute path (`/Users/<me>/.claude/hooks/tv-notify.sh`). Read the existing file first so you don't clobber my other settings; preserve them all. If the file already has a `Stop` hook pointing at a different command, ask me before touching it.

5. Verify `jq` is installed (it ships with macOS). If not, install it with `brew install jq`.

6. Once everything's wired, tell me to open a NEW terminal and run `claude` there (settings are loaded at session start). Explain that the very first reply in that new session should produce a popup on the TV.

7. Summarise what you changed in 3-5 bullet points so I have a record.

Important constraints:
- Do NOT push anything or make network calls beyond the smoke test and the file download.
- Do NOT modify anything outside `~/.claude/`.
- If `~/.claude/settings.json` doesn't exist yet, create a minimal one with just the hooks block.
- If you run into any ambiguity (e.g. settings.json has a conflicting hook, or jq isn't available and brew isn't either), stop and ask me.
```

---

## What the prompt will produce

After running, you'll have:

- `~/.claude/hooks/tv-notify.sh` — the hook script with your TV IP baked in.
- `~/.claude/settings.json` — updated with the Stop hook entry.
- One smoke-test popup already shown on the TV to confirm connectivity.
- A brief summary of the changes Claude made.

If anything goes sideways mid-install (wrong IP, TV asleep, `jq` missing, etc.), the prompt instructs Claude to stop and ask rather than power through.
