import os
import xml.etree.ElementTree as ET
import re

# --- CONFIGURATION ---
# The path to your XML file
XML_FILE = 'batess2_config.xml'

# We set this to the folder BEFORE "assets" because the XML paths 
# usually start with the word "assets/"
BASE_DIR = r'C:\Users\Admin (K)\Desktop\bates motel 2014 tour'

# File extensions we are looking for
EXTENSIONS = ('.png', '.jpg', '.jpeg', '.gif', '.mp3', '.mp4', '.flv', '.wav', '.swf')

def extract_all_paths(xml_file):
    if not os.path.exists(xml_file):
        print(f"Error: {xml_file} not found.")
        return set()

    tree = ET.parse(xml_file)
    root = tree.getroot()
    found_paths = set()

    # Iterate through every single element in the XML
    for el in root.iter():
        # 1. Check all attributes (path, assetPath, value, up, over, etc.)
        for attr_name, attr_value in el.attrib.items():
            if isinstance(attr_value, str) and attr_value.lower().endswith(EXTENSIONS):
                found_paths.add(attr_value.strip().replace('\\', '/'))

        # 2. Check the text content of the tag (for <TEXTURE>, <SOUND>, etc)
        if el.text and el.text.strip().lower().endswith(EXTENSIONS):
            found_paths.add(el.text.strip().replace('\\', '/'))

    return found_paths

def run_audit():
    print("--- STARTING ASSET AUDIT ---")
    xml_paths = extract_all_paths(XML_FILE)
    
    if not xml_paths:
        print("No assets found in XML to check.")
        return

    missing = []
    present = []

    for rel_path in sorted(xml_paths):
        # Normalize path for Windows compatibility
        full_path = os.path.join(BASE_DIR, rel_path.lstrip('/'))
        
        if os.path.exists(full_path):
            present.append(rel_path)
        else:
            missing.append(rel_path)

    # --- REPORTING ---
    print(f"\nAudit complete for: {BASE_DIR}")
    print(f"Total Unique Assets Referenced in XML: {len(xml_paths)}")
    print(f"Total Found: {len(present)}")
    print(f"Total Missing: {len(missing)}")

    if missing:
        print("\n--- MISSING FILES ---")
        for m in missing:
            print(f"[ ] MISSING: {m}")
    else:
        print("\n[+] SUCCESS: All files accounted for!")

    print("\n--- END OF REPORT ---")

if __name__ == "__main__":
    run_audit()