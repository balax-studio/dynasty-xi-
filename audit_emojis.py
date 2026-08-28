import os
import re

EMOJI_PATTERN = re.compile(
    r'[\U00010000-\U0010ffff]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50]|[\u2B06]|[\u2194-\u21AA]|[\u200D]|[\uFE0F]'
)

TARGET_DIRS = ['lib', 'test']
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

matches = []

for target_dir in TARGET_DIRS:
    full_path = os.path.join(BASE_DIR, target_dir)
    for root, _, files in os.walk(full_path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                for line_idx, line in enumerate(lines, start=1):
                    found_emojis = EMOJI_PATTERN.findall(line)
                    if found_emojis:
                        matches.append({
                            'file': os.path.relpath(file_path, BASE_DIR),
                            'line': line_idx,
                            'count': len(found_emojis),
                        })

print(f"Total remaining emoji occurrences: {len(matches)}")
if matches:
    for m in matches[:20]:
        print(f"  {m['file']}:{m['line']} ({m['count']} emojis)")
else:
    print("Zero emojis found! 100% clean codebase.")
