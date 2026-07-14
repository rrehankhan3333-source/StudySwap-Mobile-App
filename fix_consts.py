import os

def strip_const_from_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    new_content = []
    length = len(content)
    i = 0
    
    while i < length:
        if content[i:i+6] == 'const ':
            start_expr = i + 6
            j = start_expr
            while j < length and content[j].isspace():
                j += 1
            
            brace_stack = []
            expr_end = j
            
            if j < length and content[j] in ('[', '{'):
                bracket = content[j]
                opp = ']' if bracket == '[' else '}'
                brace_stack.append(bracket)
                j += 1
                while j < length and brace_stack:
                    c = content[j]
                    if c == bracket:
                        brace_stack.append(bracket)
                    elif c == opp:
                        brace_stack.pop()
                    j += 1
                expr_end = j
            elif j < length and (content[j].isalnum() or content[j] == '_'):
                while j < length and (content[j].isalnum() or content[j] in ('_', '.')):
                    j += 1
                
                # Check for parenthesis
                k = j
                while k < length and content[k].isspace():
                    k += 1
                if k < length and content[k] == '(':
                    brace_stack.append('(')
                    j = k + 1
                    while j < length and brace_stack:
                        c = content[j]
                        if c == '(':
                            brace_stack.append('(')
                        elif c == ')':
                            brace_stack.pop()
                        j += 1
                    expr_end = j
                else:
                    expr_end = j
            else:
                expr_end = j
            
            expr = content[start_expr:expr_end]
            if 'AppTheme.' in expr:
                modified = True
                i = start_expr  # skip the word 'const '
            else:
                new_content.append(content[i])
                i += 1
        else:
            new_content.append(content[i])
            i += 1
            
    if modified:
        new_text = ''.join(new_content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_text)
        print(f"Fixed consts in {filepath}")

def run():
    lib_dir = r"r:\CUI\6th Semester\Mobile Application Dev\Flutter Projectrs\semeste_project\lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                strip_const_from_file(filepath)

if __name__ == "__main__":
    run()
