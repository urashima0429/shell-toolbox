import re
import sys
from collections import Counter

if len(sys.argv) != 3:
    print("Usage: python3 count_bib_usage.py main.aux refs.bib")
    sys.exit(1)

aux_path = sys.argv[1]
bib_path = sys.argv[2]

with open(aux_path, encoding="utf-8") as f:
    aux_text = f.read()

citations = re.findall(r"\\citation\{([^}]+)\}", aux_text)

cited_keys = []
for c in citations:
    for key in c.split(","):
        k = key.strip()
        if k:
            cited_keys.append(k)

counter = Counter(cited_keys)

with open(bib_path, encoding="utf-8") as f:
    bib_text = f.read()

bib_keys = re.findall(r"@\w+\{([^,]+),", bib_text)

usage = [(counter[key], key) for key in bib_keys]
usage.sort(key=lambda x: (-x[0], x[1]))

total = len(bib_keys)
used = sum(1 for cnt, _ in usage if cnt > 0)
unused = total - used

print("##### START usage_sorted #####")
for count, key in usage:
    print(f"{count:3d}  {key}")
print("##### END usage_sorted #####")
print()
print("##### SUMMARY #####")
print(f"Total entries : {total}")
print(f"Used entries  : {used}")
print(f"Unused entries: {unused}")
print("##### END SUMMARY #####")
