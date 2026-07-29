import os
import shutil

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"
files_to_delete = [
    os.path.join(lib_dir, r"features\paymentScreen\paypal\paypal_payment.dart"),
    os.path.join(lib_dir, r"features\paymentScreen\paypal\paypal_services.dart"),
    os.path.join(lib_dir, r"features\paymentScreen\StripePayment.dart"),
    os.path.join(lib_dir, r"features\subscription\Subscription.dart"),
    os.path.join(lib_dir, r"features\subscription\SubscriptionHistory.dart"),
    os.path.join(lib_dir, r"models\purchaseSubscription.dart"),
    os.path.join(lib_dir, r"models\Subscription.dart")
]

for f in files_to_delete:
    if os.path.exists(f):
        os.remove(f)
        print(f"Deleted {f}")
    else:
        print(f"File not found: {f}")

# Also remove the paypal directory if empty
paypal_dir = os.path.join(lib_dir, r"features\paymentScreen\paypal")
if os.path.exists(paypal_dir) and not os.listdir(paypal_dir):
    os.rmdir(paypal_dir)
    print(f"Deleted directory {paypal_dir}")

# Update pubspec.yaml
pubspec_path = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\pubspec.yaml"
with open(pubspec_path, 'r', encoding='utf-8') as f:
    pubspec_lines = f.readlines()

new_pubspec = []
for line in pubspec_lines:
    if 'razorpay_flutter:' in line or 'flutter_stripe:' in line or 'flutter_paystack:' in line or 'flutterwave_standard:' in line:
        continue
    new_pubspec.append(line)

with open(pubspec_path, 'w', encoding='utf-8') as f:
    f.writelines(new_pubspec)

print("Updated pubspec.yaml")
