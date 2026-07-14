import os
import re

SCREENS_DIR = r"r:\CUI\6th Semester\Mobile Application Dev\Flutter Projectrs\semeste_project\lib\screens"

def refactor_screen(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # 1. Replace background colors
    # replaces: Color(0xffF8FAFC), Color(0xFFF8FAFC), const Color(0xffF8FAFC), const Color(0xFFF8FAFC)
    content = re.sub(r'const\s+Color\(0x[fF]8[fF][aA][fF][cC]\)', 'AppTheme.bgLight', content)
    content = re.sub(r'Color\(0x[fF]8[fF][aA][fF][cC]\)', 'AppTheme.bgLight', content)
    
    # 2. Replace surface / secondary backgrounds
    # replaces: Color(0xffF1F5F9), const Color(0xffF1F5F9)
    content = re.sub(r'const\s+Color\(0x[fF]1[fF]5[fF]9\)', 'AppTheme.bgSurface', content)
    content = re.sub(r'Color\(0x[fF]1[fF]5[fF]9\)', 'AppTheme.bgSurface', content)
    content = re.sub(r"const\s+Color\(0xffF1F5F9\)", "AppTheme.bgSurface", content)
    content = re.sub(r"Color\(0xffF1F5F9\)", "AppTheme.bgSurface", content)

    # 3. Handle specific replacements for dialog backgrounds containing Colors.white
    # Dialogs, Alert dialogs, Bottom sheets, and some main containers
    # Wait, simple string replacements are safer for specific patterns.
    # In cart_screen, orders_screen, notifications_screen, messages_screen, chat_screen:
    # scaffold background and cards should use AppTheme colors.
    
    # Replace Colors.white inside card decoration templates or dialogs
    # Let's inspect some standard container and appbar white-background replacements:
    # e.g., 'backgroundColor: Colors.white,' in AppBar -> 'backgroundColor: AppTheme.bgLight,' (or bgCard if preferred, but bgLight matches scaffold)
    # Let's replace 'backgroundColor: Colors.white,' inside AppBar
    content = content.replace('backgroundColor: Colors.white,\n              elevation: 0,', 'backgroundColor: AppTheme.bgLight,\n              elevation: 0,')
    content = content.replace('backgroundColor: Colors.white,', 'backgroundColor: AppTheme.bgCard,')
    content = content.replace('surfaceTintColor: Colors.transparent,', 'surfaceTintColor: Colors.transparent,\n        backgroundColor: AppTheme.bgCard,')
    # wait, if backgroundColor was already defined on the line above/before, let's keep it safe.
    
    # Some screens have 'color: Colors.white,' inside BoxDecoration
    # Replacing it with 'color: AppTheme.bgCard,' makes it slate-800 in dark mode and white in light mode. Let's do that!
    # Wait, we need to make sure we don't break circles or buttons where white is required.
    # But card backgrounds are the main things. Let's replace:
    # 'color: Colors.white,\n          borderRadius: BorderRadius' -> 'color: AppTheme.bgCard,\n          borderRadius: BorderRadius'
    # 'color: Colors.white,\n                      borderRadius: BorderRadius' -> 'color: AppTheme.bgCard,\n                      borderRadius: BorderRadius'
    # 'color: Colors.white,\n        borderRadius: BorderRadius' -> 'color: AppTheme.bgCard,\n        borderRadius: BorderRadius'
    # 'color: Colors.white,\n      borderRadius: BorderRadius' -> 'color: AppTheme.bgCard,\n      borderRadius: BorderRadius'
    
    content = re.sub(r'color:\s+Colors\.white,\s*(?=\n\s*(?:decoration|borderRadius|shape|border|boxShadow))', 'color: AppTheme.bgCard, ', content)
    content = re.sub(r'color:\s+Colors\.white\s*,\s*(?=\n\s*(?:borderRadius|shape|border|boxShadow))', 'color: AppTheme.bgCard, ', content)
    
    # Also replace: 'color: const Color(0xffffffff)' or 'color: const Color(0xFFFFFFFF)'
    content = re.sub(r'color:\s+const\s+Color\(0x[fF]{8}\),\s*(?=\n\s*(?:borderRadius|shape|border|boxShadow))', 'color: AppTheme.bgCard, ', content)
    content = re.sub(r'color:\s+Color\(0x[fF]{8}\),\s*(?=\n\s*(?:borderRadius|shape|border|boxShadow))', 'color: AppTheme.bgCard, ', content)
    
    # Let's replace 'color: Colors.white' in BoxDecorations generally
    # Let's also check for other hardcoded light colors
    # e.g., in cart_screen:
    # color: const Color(0xffFEF2F2), -> isDarkMode ? const Color(0xff2A1C1C) : const Color(0xffFEF2F2)
    content = content.replace('color: const Color(0xffFEF2F2),', 'color: AppTheme.isDarkMode ? const Color(0xff2A1C1C) : const Color(0xffFEF2F2),')
    content = content.replace('color: const Color(0xffFEE2E2),', 'color: AppTheme.isDarkMode ? const Color(0xff4A1C1C) : const Color(0xffFEE2E2),')
    # and color: const Color(0xffE2E8F0) (divider / borders) -> AppTheme.borderLight
    content = re.sub(r'const\s+Color\(0xffE2E8F0\)', 'AppTheme.borderLight', content)
    content = re.sub(r'Color\(0xffE2E8F0\)', 'AppTheme.borderLight', content)
    content = re.sub(r'const\s+Color\(0xffCBD5E1\)', 'AppTheme.borderMedium', content)
    content = re.sub(r'Color\(0xffCBD5E1\)', 'AppTheme.borderMedium', content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Refactored {os.path.basename(filepath)}")

def run():
    for file in os.listdir(SCREENS_DIR):
        if file.endswith('.dart') and file not in ('settings_screen.dart', 'splash_screen.dart'):
            refactor_screen(os.path.join(SCREENS_DIR, file))

if __name__ == "__main__":
    run()
