#!/usr/bin/env python3
import sys
from pathlib import Path

if len(sys.argv) != 2:
    print("Usage: python3 json_trace.py path/to/file.json")
    sys.exit(2)

p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8", errors="replace")

in_string = False
escaped = False
stack = []
events = []  # (i, action, char, snippet_start, snippet_end)

def snippet(i, r=30):
    start = max(0, i-r)
    end = min(len(s), i+r)
    return s[start:end].replace("\n", "\\n")

for i, ch in enumerate(s):
    # record before-change stack depth occasionally for context
    if escaped:
        escaped = False
        continue
    if ch == "\\":
        escaped = True
        continue
    if ch == '"':
        in_string = not in_string
        events.append((i, "quote", '"', snippet(i)))
        continue
    if in_string:
        continue
    if ch == "{":
        stack.append(("{", i))
        events.append((i, "push", "{", snippet(i)))
    elif ch == "[":
        stack.append(("[", i))
        events.append((i, "push", "[", snippet(i)))
    elif ch == "}":
        if not stack or stack[-1][0] != "{":
            events.append((i, "mismatch_close", "}", snippet(i)))
            break
        stack.pop()
        events.append((i, "pop", "}", snippet(i)))
    elif ch == "]":
        if not stack or stack[-1][0] != "[":
            events.append((i, "mismatch_close", "]", snippet(i)))
            break
        stack.pop()
        events.append((i, "pop", "]", snippet(i)))

# If loop finished, but stack not empty, report eof_unclosed
if not any(e[1].startswith("mismatch") for e in events) and stack:
    events.append((len(s), "eof_unclosed", None, snippet(len(s))))

# Print the trace summary (only the last 100 events to keep output reasonable)
print("file:", p)
print("file size:", len(s))
print("total events recorded:", len(events))
print("LAST 200 events (index,action,char,context):")
for e in events[-200:]:
    i, action, ch, ctxt = e
    print(f"{i:8d} {action:14s} {repr(ch):6s} context={ctxt}")
# Also print final stack snapshot
print("\nFINAL STACK (bottom->top):")
for ty, idx in stack:
    print(f"  {ty} @ {idx}   snippet: {snippet(idx)}")
if any(e[1].startswith("mismatch") for e in events):
    print("\nA mismatch closing token was found earlier. Look at the mismatch event above.")
elif stack:
    print("\nFile ended with an open stack: you need to add these closers (in reverse order):")
    print("".join('}' if t == '{' else ']' for t, _ in reversed(stack)))