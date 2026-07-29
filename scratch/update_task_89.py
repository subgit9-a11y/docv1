import os

task_file = r"c:\Users\SUBHASH\.gemini\antigravity\brain\3dd3b4a3-bccf-4420-8fd1-e20fed8cb236\task.md"

if os.path.exists(task_file):
    with open(task_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Step 8
    content = content.replace('- `[ ]` **Step 8: Build & Verification**', '- `[x]` **Step 8: Build & Verification**')
    content = content.replace('- `[ ]` Run `dart format .`', '- `[x]` Run `dart format .`')
    content = content.replace('- `[ ]` Run `flutter build apk --release`', '- `[x]` Run `flutter build apk --release`')

    # Step 9
    content = content.replace('- `[ ]` **Step 9: Documentation**', '- `[x]` **Step 9: Documentation**')
    content = content.replace('- `[ ]` Generate `migration_report.md`', '- `[x]` Generate `migration_report.md`')

    with open(task_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated task.md for step 8 and 9")
