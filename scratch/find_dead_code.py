import os
import glob

def find_dead_files():
    # 1. Collect all dart files
    all_dart_files = glob.glob('lib/**/*.dart', recursive=True)
    all_dart_files = [f.replace('\\', '/') for f in all_dart_files]
    
    # Exclude main.dart and splash screen
    excluded_files = ['lib/main.dart', 'lib/features/splash_screen.dart', 'lib/firebase_options.dart']
    files_to_check = [f for f in all_dart_files if f not in excluded_files]
    
    # 2. Read all contents to find imports
    file_contents = []
    for f in all_dart_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                file_contents.append(file.read())
        except:
            pass

    combined_content = '\n'.join(file_contents)
    
    dead_files = []
    
    for f in files_to_check:
        # Get filename and relative path parts
        filename = os.path.basename(f)
        
        # Check if the filename appears in any import statement in any file
        # A bit crude but effective for finding completely dead files
        if f"/{filename}'" not in combined_content and f"/{filename}\"" not in combined_content and f"'{filename}'" not in combined_content:
            dead_files.append(f)

    print("POTENTIALLY DEAD FILES:")
    for df in dead_files:
        print(df)

if __name__ == "__main__":
    find_dead_files()
