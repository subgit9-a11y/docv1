import os

task_file = r"c:\Users\SUBHASH\.gemini\antigravity\brain\3dd3b4a3-bccf-4420-8fd1-e20fed8cb236\task.md"

if os.path.exists(task_file):
    with open(task_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check off steps 3 to 7
    content = content.replace('- `[ ]` **Step 3: Update Dashboard (Login Home)**', '- `[x]` **Step 3: Update Dashboard (Login Home)**')
    content = content.replace('- `[ ]` Strip non-Phase 1 widgets from `login_home.dart`', '- `[x]` Strip non-Phase 1 widgets from `login_home.dart`')

    content = content.replace('- `[ ]` **Step 4: Optimize Consultation & Prescription**', '- `[x]` **Step 4: Optimize Consultation & Prescription**')
    content = content.replace('- `[ ]` Clean up `prescription_screen.dart`', '- `[x]` Clean up `prescription_screen.dart`')

    content = content.replace('- `[ ]` **Step 5: Profile Screen**', '- `[x]` **Step 5: Profile Screen**')
    content = content.replace('- `[ ]` Update `profile.dart` with Phase 1 details', '- `[x]` Update `profile.dart` with Phase 1 details')

    content = content.replace('- `[ ]` **Step 6: Project Restructure**', '- `[x]` **Step 6: Project Restructure**')
    content = content.replace('- `[ ]` Clean up folders to strict Clean Architecture', '- `[x]` Clean up folders to strict Clean Architecture')

    content = content.replace('- `[ ]` **Step 7: Code Quality & Performance**', '- `[x]` **Step 7: Code Quality & Performance**')
    content = content.replace('- `[ ]` Fix all `dart analyze` errors', '- `[/]` Fix all `dart analyze` errors')
    content = content.replace('- `[ ]` Remove debug prints and hardcoded secrets', '- `[x]` Remove debug prints and hardcoded secrets')

    with open(task_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated task.md")
