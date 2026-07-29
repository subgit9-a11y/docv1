import os

task_file = r"c:\Users\SUBHASH\.gemini\antigravity\brain\3dd3b4a3-bccf-4420-8fd1-e20fed8cb236\task.md"

if os.path.exists(task_file):
    with open(task_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Step 1
    content = content.replace('- `[ ]` **Step 1: Remove PayPal and Stripe Completely**', '- `[x]` **Step 1: Remove PayPal and Stripe Completely**')
    content = content.replace('- `[ ]` Delete PayPal files', '- `[x]` Delete PayPal files')
    content = content.replace('- `[ ]` Delete Stripe files', '- `[x]` Delete Stripe files')
    content = content.replace('- `[ ]` Update `pubspec.yaml` (Remove Stripe, PayPal, Razorpay)', '- `[x]` Update `pubspec.yaml` (Remove Stripe, PayPal, Razorpay)')
    content = content.replace('- `[ ]` Update `lib/core/network/apis.dart` (Remove endpoints)', '- `[x]` Update `lib/core/network/apis.dart` (Remove endpoints)')
    content = content.replace('- `[ ]` Update `lib/main.dart` (Remove routes)', '- `[x]` Update `lib/main.dart` (Remove routes)')

    # Step 2
    content = content.replace('- `[ ]` **Step 2: Remove Subscription System**', '- `[x]` **Step 2: Remove Subscription System**')
    content = content.replace('- `[ ]` Delete Subscription UI files', '- `[x]` Delete Subscription UI files')
    content = content.replace('- `[ ]` Delete Subscription models', '- `[x]` Delete Subscription models')
    content = content.replace('- `[ ]` Update `lib/main.dart` (Remove subscription routes)', '- `[x]` Update `lib/main.dart` (Remove subscription routes)')
    content = content.replace('- `[ ]` Remove from Navigation Drawer/Bottom Nav', '- `[x]` Remove from Navigation Drawer/Bottom Nav')

    with open(task_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated task.md")
