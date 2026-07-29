import os
import re

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"

# 1. Delete PaymentGateway.dart
pg_path = os.path.join(lib_dir, r"features\paymentScreen\PaymentGateway.dart")
if os.path.exists(pg_path):
    os.remove(pg_path)
    print("Deleted PaymentGateway.dart")

# 2. Modify Setting.dart
setting_path = os.path.join(lib_dir, r"features\setting\Setting.dart")
if os.path.exists(setting_path):
    with open(setting_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r"import\s+'[^']*SubscriptionHistory.dart';\n", "", content)
    # The hasSubscription block is if (hasSubscription) ...[ ... ]
    # The easiest way to remove it is string replacement if it's exact, or regex.
    # Let's remove the whole drawer_subscription_history list item block
    content = re.sub(r"if\s*\(hasSubscription\)\s*\.\.\.\[[\s\S]*?builder:\s*\(context\)\s*=>\s*SubscriptionHistory\(\),\s*\),\s*\),\s*\],", "", content)
    content = re.sub(r"final\s+hasSubscription\s*=\s*false;\n", "", content)
    with open(setting_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Cleaned Setting.dart")

# 3. Clean network APIs
network_api = os.path.join(lib_dir, r"core\network\network_api.dart")
if os.path.exists(network_api):
    with open(network_api, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r"import 'package:doctro/core/models/Subscription.dart';\n", "", content)
    content = re.sub(r"import 'package:doctro/core/models/purchaseSubscription.dart';\n", "", content)
    content = re.sub(r"@GET\(Apis\.subscription\)[\s\S]*?Future<SubscriptionPlan> subscriptionRequest\(\);", "", content)
    content = re.sub(r"@POST\(Apis\.purchase_subscription\)[\s\S]*?Future<PurchaseSubscription> purchaseSubscriptionRequest\(@Body\(\) body\);", "", content)
    with open(network_api, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Cleaned network_api.dart")

# 4. Clean models
def clean_model(file_path):
    if not os.path.exists(file_path): return
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    new_lines = []
    for line in lines:
        if 'subscriptionStatus' in line or 'subscription_status' in line:
            if 'this.subscriptionStatus' in line or 'subscriptionStatus =' in line or "data['subscription_status']" in line:
                continue
            if 'int? subscriptionStatus;' in line:
                continue
        if 'subscriptionId' in line or 'subscription_id' in line or 'Subscription?' in line or 'Subscription.fromJson' in line or "data['subscription']" in line or 'class Subscription' in line or 'Subscription({this.id, this.name});' in line:
            # For FinanceDetails.dart we have a lot of subscription lines, this is a bit rough but works for simple lines
            if 'class Subscription {' in line:
                break # Just skip the rest of the file since it's at the end
            continue
        new_lines.append(line)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print(f"Cleaned {file_path}")

clean_model(os.path.join(lib_dir, r"core\models\doctor_profile.dart"))
clean_model(os.path.join(lib_dir, r"core\models\FinanceDetails.dart"))
clean_model(os.path.join(lib_dir, r"core\models\login.dart"))
clean_model(os.path.join(lib_dir, r"core\models\otp_verify.dart"))

# 5. Build runner to regenerate network_api.g.dart
print("Run flutter pub run build_runner build --delete-conflicting-outputs next")
