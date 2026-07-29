import collections
import re

log_path = r"C:\Users\SUBHASH\.gemini\antigravity\brain\3dd3b4a3-bccf-4420-8fd1-e20fed8cb236\.system_generated\tasks\task-718.log"

errors = collections.defaultdict(list)

with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        line = line.strip()
        if line.startswith("error -"):
            m = re.search(r"error - ([^:]+):", line)
            if m:
                file_name = m.group(1)
                errors[file_name].append(line)

output_path = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\scratch\errors_grouped.txt"
with open(output_path, "w", encoding="utf-8") as out:
    for f, errs in errors.items():
        out.write(f"File: {f} ({len(errs)} errors)\n")
        for e in errs[:10]:  # print up to 10 errors per file
            out.write(f"  {e}\n")
        if len(errs) > 10:
            out.write(f"  ... and {len(errs) - 10} more\n")
        out.write("-" * 50 + "\n")
print(f"Done writing grouped errors! Total errors: {sum(len(e) for e in errors.values())}")
