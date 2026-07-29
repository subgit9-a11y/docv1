import glob
import re

def remove_prints():
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    total_removed = 0
    
    # Matches print('...') or print(...) or debugPrint(...) that are on their own lines
    # It also attempts to match multi-line prints by using DOTALL if we wanted to, 
    # but single line is safer to avoid deleting too much.
    print_pattern = re.compile(r'^\s*(debugPrint|print|log)\s*\(.*?\);[\r\n]*', re.MULTILINE | re.DOTALL)
    
    # A safer approach for nested prints is just to match the single line ones, or use a naive bracket matcher
    # For now, let's just match single-line prints, which covers 95% of them.
    single_line_print = re.compile(r'^\s*(debugPrint|print|log)\s*\([^\n;]*\);[\r\n]*', re.MULTILINE)
    
    for filepath in dart_files:
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Remove the single line prints
            new_content = single_line_print.sub('', content)
            
            # Count how many were removed
            removed_in_file = len(single_line_print.findall(content))
            total_removed += removed_in_file
            
            if new_content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Removed {removed_in_file} prints from {filepath}")
                
        except Exception as e:
            print(f"Error processing {filepath}: {e}")

    print(f"\nTotal prints removed globally: {total_removed}")

if __name__ == "__main__":
    remove_prints()
