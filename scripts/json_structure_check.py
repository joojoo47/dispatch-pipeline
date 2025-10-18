#!/usr/bin/env python3
import sys

if len(sys.argv) != 2:
    print("Usage: python3 json_structure_check.py path/to/file.json")
    sys.exit(2)

path = sys.argv[1]
s = open(path, "rb").read().decode("utf-8", errors="replace")

in_string = False
escaped = False
stack = []  # store tuples (char, index)
first_problem = None

for i, ch in enumerate(s):
    if escaped:
        escaped = False
        continue
    if ch == "\\":
        escaped = True
        continue
    if ch == '"':
        in_string = not in_string
        continue
    if in_string:
        continue
    # Only examine structural chars when not inside a string
    if ch == "{":
        stack.append(("{", i))
    elif ch == "[":
        stack.append(("[", i))
    elif ch == "}":
        if not stack or stack[-1][0] != "{":
            first_problem = ("unexpected_closing", ch, i, stack.copy())
            break
        stack.pop()
    elif ch == "]":
        if not stack or stack[-1][0] != "[":
            first_problem = ("unexpected_closing", ch, i, stack.copy())
            break
        stack.pop()

if first_problem is None and stack:
    first_problem = ("eof_unclosed", None, len(s)-1, stack.copy())

def show_context(pos, radius=80):
    start = max(0, pos - radius)
    end = min(len(s), pos + radius)
    excerpt = s[start:end]
    # make control chars visible
    return (start, end, excerpt.replace("\n", "\\n"))

if first_problem is None:
    print("No structural problem found by the simple scanner. File may still be invalid due to token-level issues.")
    sys.exit(0)

kind, ch, pos, stack_snapshot = first_problem
print("Problem kind:", kind)
if ch is not None:
    print("Problem char:", repr(ch))
print("Problem index (byte position):", pos)
print("Stack snapshot at problem (bottom->top):", [x[0] + "@" + str(x[1]) for x in stack_snapshot])
start, end, ctxt = show_context(pos)
print(f"\nContext around position {pos} (bytes {start}-{end}):\n{ctxt}\n")
print("Notes:")
if kind == "unexpected_closing":
    print("- An unexpected closing bracket/brace was found. Likely either a stray ']' or '}' or a missing matching opening brace earlier.")
    print("- If the unexpected closing is right before a string key (e.g. ...]\"key\"...), the real problem is likely a missing comma.")
elif kind == "eof_unclosed":
    print("- The file ended while the stack still expected closing braces/brackets. Some closing '}' or ']' are missing near end-of-file.")
print("\nIf you paste the output here I will propose a precise edit (and can produce a .fixed file).")