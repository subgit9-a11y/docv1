import re

filepath = r"lib/features/profile/view_models/profile_view_model.dart"
lines = open(filepath, 'r', encoding='utf-8').readlines()

# Truncate to the end of doctorProfile method (which is at line 292, index 291)
truncated_lines = lines[:292]

# Add setState helper and class closing brace
class_body = "".join(truncated_lines)

# Fix method signatures to accept BuildContext context
class_body = class_body.replace("Future<BaseModel<UpdateProfile>> updateProfile() async", "Future<BaseModel<UpdateProfile>> updateProfile(BuildContext context) async")
class_body = class_body.replace("Future<BaseModel<DoctorProfile>> doctorProfile() async", "Future<BaseModel<DoctorProfile>> doctorProfile(BuildContext context) async")

# List of variables to remove the leading underscore prefix
vars_to_fix = [
    'pName', 'pDob', 'selectedDate', 'genderSelect', 'pExperience', 'aAppointmentFees',
    'vAppointmentFees', 'pStartTime', 'pEndTime', 'pTimeSlot', 'pDesc', 'pBasedOn',
    'selectedPopular', 'proImage', 'valueExpertise', 'valueCategories', 'valueTreatment',
    'pCollege', 'pCollegeYear', 'pCertificate', 'pCertificateYear',
    'degree', 'college', 'completeYear', 'certificate', 'year', 'valueDegree', 'valueCollege',
    'valueYear', 'certificateValue', 'certificateYearValue',
    'pDegree'
]

for v in vars_to_fix:
    class_body = class_body.replace(f'_{v}', v)

# Add the setState helper method before closing the class
setState_helper = """
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}
"""

class_body = class_body.rstrip()
if class_body.endswith('}'):
    # Replace the last } with the setState helper and new }
    class_body = class_body[:-1] + setState_helper
else:
    class_body = class_body + setState_helper

open(filepath, 'w', encoding='utf-8').write(class_body)
print("Finished rewriting and cleaning profile_view_model.dart!")
