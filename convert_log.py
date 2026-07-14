import os

filepath = r"r:\CUI\6th Semester\Mobile Application Dev\Flutter Projectrs\semeste_project\analyze_res.txt"
output_path = r"r:\CUI\6th Semester\Mobile Application Dev\Flutter Projectrs\semeste_project\analyze_res_utf8.txt"

if os.path.exists(filepath):
    try:
        with open(filepath, 'r', encoding='utf-16le') as f:
            content = f.read()
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Successfully converted log file to UTF-8")
    except Exception as e:
        print(f"Error during conversion: {e}")
else:
    print("Log file does not exist")
