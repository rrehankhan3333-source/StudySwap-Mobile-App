import os
import re
from fpdf import FPDF

class VivaGuidePDF(FPDF):
    def __init__(self):
        super().__init__()
        self.set_margins(15, 15, 15)
        self.set_auto_page_break(True, 15)
        
    def header(self):
        if self.page_no() > 1:
            self.set_font('Helvetica', 'I', 8)
            self.set_text_color(100, 110, 120)
            self.cell(0, 10, 'StudySwap - Project Viva Study Guide & Architectural Blueprint', 0, 0, 'L')
            self.cell(0, 10, f'Page {self.page_no()}', 0, 1, 'R')
            self.set_draw_color(226, 232, 240)
            self.line(15, 22, 195, 22)
            self.ln(5)

    def footer(self):
        if self.page_no() > 1:
            self.set_y(-15)
            self.set_font('Helvetica', 'I', 8)
            self.set_text_color(100, 110, 120)
            self.cell(0, 10, 'Confidential - Created for Viva Preparation', 0, 0, 'C')

    def draw_cover_page(self):
        self.add_page()
        # Bold color header band
        self.set_fill_color(79, 70, 229)
        self.rect(0, 0, 210, 100, 'F')
        
        # Title inside band
        self.set_font('Helvetica', 'B', 32)
        self.set_text_color(255, 255, 255)
        self.set_y(35)
        self.cell(0, 12, 'STUDY SWAP', 0, 1, 'C')
        
        # Subtitle
        self.set_font('Helvetica', 'B', 14)
        self.set_text_color(226, 232, 240)
        self.cell(0, 10, 'PROJECT VIVA STUDY GUIDE & BLUEPRINT', 0, 1, 'C')
        
        # Details section below band
        self.set_draw_color(79, 70, 229)
        self.set_y(120)
        
        # Author details
        self.set_font('Helvetica', 'B', 16)
        self.set_text_color(15, 23, 42)
        self.cell(0, 10, 'Prepared for Course Viva', 0, 1, 'C')
        self.ln(5)
        
        self.set_font('Helvetica', '', 11)
        self.set_text_color(71, 85, 105)
        details = [
            ("Project Name:", "StudySwap Marketplace"),
            ("Course:", "Mobile Application Development (MAD)"),
            ("Semester:", "6th Semester / Bachelor of Computer Science"),
            ("Technology Stack:", "Flutter (Dart), Firebase Auth, Cloud Firestore, Firebase Storage"),
            ("Prepared By:", "Rehan Khan"),
            ("Academic Session:", "2026"),
            ("Document Scope:", "Architecture, CRUD Operations, workflows, and Teacher-Level Q/A")
        ]
        
        for key, val in details:
            self.set_x(30)
            self.set_font('Helvetica', 'B', 10)
            self.cell(40, 7, key, 0, 0)
            self.set_font('Helvetica', '', 10)
            self.cell(100, 7, val, 0, 1)
            
        # Draw a beautiful badge/border on the cover
        self.set_draw_color(109, 93, 246)
        self.set_line_width(0.8)
        self.rect(8, 8, 194, 281)
        self.set_line_width(0.2)
        
        self.ln(25)
        self.set_font('Helvetica', 'I', 9)
        self.set_text_color(148, 163, 184)
        self.cell(0, 6, "Note: This study guide contains actual extraction and analysis of the active codebase.", 0, 1, 'C')
        self.cell(0, 6, "Do not share outside of immediate StudySwap course review teams.", 0, 1, 'C')

def compile_viva_guide(output_path, sections_dir):
    pdf = VivaGuidePDF()
    pdf.draw_cover_page()
    
    # Sort section files
    sec_files = sorted([f for f in os.listdir(sections_dir) if f.endswith('.txt')])
    
    # Current formatting state variables
    in_code_block = False
    code_lines = []
    
    table_headers = []
    table_rows = []
    in_table = False
    
    for sec_file in sec_files:
        filepath = os.path.join(sections_dir, sec_file)
        print(f"Parsing {sec_file}...")
        
        pdf.add_page()
        
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for raw_line in lines:
            line = raw_line.rstrip('\n')
            
            # Handle Code Blocks Toggle
            if line.strip().startswith('```'):
                if in_code_block:
                    in_code_block = False
                    # Write the accumulated code block
                    # Grey background
                    pdf.set_fill_color(248, 250, 252)
                    pdf.set_draw_color(226, 232, 240)
                    pdf.set_font('Courier', '', 8)
                    pdf.set_text_color(15, 23, 42)
                    
                    code_text = "\n".join(code_lines)
                    # We compute exact height or write line by line for safety & page breaks
                    for cl in code_lines:
                        # Replace tabs with spaces
                        formatted_cl = cl.replace('\t', '    ')
                        # Wrap line if it is wider than page width
                        if len(formatted_cl) > 85:
                            formatted_cl = formatted_cl[:82] + "..."
                        pdf.cell(0, 4.5, formatted_cl, 0, 1, 'L', fill=True)
                    pdf.ln(2)
                    code_lines = []
                else:
                    in_code_block = True
                continue
                
            if in_code_block:
                code_lines.append(line)
                continue
                
            # Handle Tables
            if line.strip().startswith('|') and '|' in line[1:]:
                # Check if separator row
                if re.match(r'^[\s|:-]+$', line):
                    continue
                parts = [p.strip() for p in line.split('|')[1:-1]]
                if not in_table:
                    in_table = True
                    table_headers = parts
                else:
                    table_rows.append(parts)
                continue
            elif in_table:
                # Table ended, render it
                in_table = False
                pdf.set_font('Helvetica', 'B', 8.5)
                pdf.set_fill_color(79, 70, 229)
                pdf.set_text_color(255, 255, 255)
                pdf.set_draw_color(226, 232, 240)
                
                # Check column count
                col_cnt = len(table_headers)
                if col_cnt == 0:
                    continue
                col_w = int(180 / col_cnt)
                
                # Header row
                for h in table_headers:
                    pdf.cell(col_w, 7, h, 1, 0, 'C', fill=True)
                pdf.ln(7)
                
                # Rows
                pdf.set_font('Helvetica', '', 8)
                pdf.set_text_color(15, 23, 42)
                row_fill = False
                for r in table_rows:
                    pdf.set_fill_color(248, 250, 252) if row_fill else pdf.set_fill_color(255, 255, 255)
                    # Pad rows to align column dimensions
                    for idx, c in enumerate(r):
                        if idx < col_cnt:
                            # Wrap text inside cell safely
                            val = c
                            if len(val) > int(col_w * 0.45):
                                val = val[:int(col_w * 0.43)] + "..."
                            pdf.cell(col_w, 6, val, 1, 0, 'L', fill=True)
                    pdf.ln(6)
                    row_fill = not row_fill
                pdf.ln(3)
                table_headers = []
                table_rows = []
            
            # Format Headings
            if line.startswith('# '):
                # Major Title
                pdf.ln(5)
                pdf.set_font('Helvetica', 'B', 22)
                pdf.set_text_color(79, 70, 229)
                pdf.cell(0, 10, line[2:], 0, 1, 'L')
                pdf.ln(3)
            elif line.startswith('## '):
                # H1 Heading
                pdf.ln(4)
                # Colored side block
                x = pdf.get_x()
                y = pdf.get_y()
                pdf.set_fill_color(79, 70, 229)
                pdf.rect(x, y + 1, 4, 7, 'F')
                pdf.set_font('Helvetica', 'B', 13)
                pdf.set_text_color(15, 23, 42)
                pdf.set_x(x + 8)
                pdf.cell(0, 9, line[3:], 0, 1, 'L')
                pdf.ln(2)
            elif line.startswith('### '):
                # H2 Subsection
                pdf.ln(3)
                pdf.set_font('Helvetica', 'B', 10.5)
                pdf.set_text_color(109, 93, 246)
                pdf.cell(0, 7, line[4:], 0, 1, 'L')
                pdf.ln(1)
            elif line.strip().startswith('- ') or line.strip().startswith('* '):
                # Bullet list item
                pdf.set_font('Helvetica', '', 9.5)
                pdf.set_text_color(15, 23, 42)
                # Indent bullet slightly
                pdf.set_x(20)
                pdf.cell(4, 5.5, chr(149), 0, 0, 'L')
                bullet_txt = line.strip()[2:]
                pdf.multi_cell(0, 5.5, bullet_txt, ln=True)
            elif re.match(r'^\d+\.\s', line.strip()):
                # Numbered list item
                pdf.set_font('Helvetica', '', 9.5)
                pdf.set_text_color(15, 23, 42)
                pdf.set_x(20)
                match = re.match(r'^(\d+\.)\s(.*)', line.strip())
                num_lbl, content = match.group(1), match.group(2)
                pdf.cell(8, 5.5, num_lbl, 0, 0, 'L')
                pdf.multi_cell(0, 5.5, content, ln=True)
            else:
                # Standard paragraph line
                if line.strip() == '':
                    pdf.ln(2.5)
                else:
                    pdf.set_font('Helvetica', '', 9.5)
                    pdf.set_text_color(71, 85, 105)
                    pdf.multi_cell(0, 5.5, line, ln=True)
                    
    pdf.output(output_path)
    print(f"Successfully compiled guide PDF to: {output_path}")

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.abspath(__file__))
    sdir = os.path.join(base_dir, 'sections')
    out = os.path.join(os.path.dirname(base_dir), 'StudySwap_Viva_Study_Guide.pdf')
    
    if not os.path.exists(sdir):
        os.makedirs(sdir)
        
    compile_viva_guide(out, sdir)
