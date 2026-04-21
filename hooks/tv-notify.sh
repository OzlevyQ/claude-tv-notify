#!/bin/bash
# Claude Code Stop hook → TvOverlay notification on Android TV.
# Takes the LAST assistant message and summarizes it in Hebrew via `claude -p`.

# Recursion guard: the claude -p invocation would otherwise re-trigger this hook.
if [[ -n "$TV_NOTIFY_RUNNING" ]]; then
  exit 0
fi

TV="http://YOUR_TV_IP:5001/notify"

INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty')
TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')
PROJECT=$(basename "${CWD:-$PWD}")

# Raw text of the single last assistant message (strip code fences, flatten whitespace)
RAW=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  RAW=$(jq -r '
      select(.type=="assistant" and .message.role=="assistant")
      | (.message.content
         | if type=="array" then map(select(.type=="text").text) | join(" ") else . end)
      | select(. != null)
      | gsub("\\s+"; " ")
      | gsub("^\\s+|\\s+$"; "")
      | select(length > 0)
      ' "$TRANSCRIPT" 2>/dev/null \
    | tail -1 \
    | sed -E 's/```[^`]*```//g; s/`[^`]*`//g' \
    | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')
fi

# Summarize the last message in Hebrew via claude -p haiku. Fallback: raw truncated.
BODY=""
if [[ -n "$RAW" ]] && command -v claude >/dev/null 2>&1; then
  PROMPT="The text below is an assistant's response from a coding session. Summarize what the assistant did or answered, in ONE short Hebrew sentence (up to 15 words). Return ONLY the Hebrew sentence, with no preamble, no quotes, no markdown.

BEGIN_TEXT
${RAW}
END_TEXT"
  BODY=$(TV_NOTIFY_RUNNING=1 perl -e 'alarm shift; exec @ARGV' 25 claude -p --model haiku "$PROMPT" 2>/dev/null \
    | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')
fi

if [[ -z "$BODY" ]]; then
  BODY="${RAW:0:250}"
  [[ ${#RAW} -gt 250 ]] && BODY="${BODY}…"
fi
[[ -z "$BODY" ]] && BODY="(אין טקסט בתשובה האחרונה)"

MESSAGE="📁 ${PROJECT}"$'\n\n'"${BODY}"

PAYLOAD=$(jq -cn \
  --arg title "🤖 Claude סיים" \
  --arg msg "$MESSAGE" \
  --arg src "Claude Code" \
  '{title:$title, message:$msg, source:$src,
    smallIcon:"mdi:robot-happy", smallIconColor:"#CC785C",
    largeIcon:"mdi:check-circle",
    corner:"top_start", duration:15}')

curl -s -m 3 -X POST "$TV" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" > /dev/null 2>&1 &

exit 0
