import os
import xml.etree.ElementTree as ET

# Path to XML and local assets folder
XML_FILE = r"C:\Users\Admin (K)\Desktop\bates motel 2014 tour\xml\batess2_config.xml"
ASSETS_FOLDER = r"C:\Users\Admin (K)\Desktop\bates motel 2014 tour"

# Parse XML
tree = ET.parse(XML_FILE)
root = tree.getroot()

# Collect all asset paths
asset_paths = []

for elem in root.iter():
    path = elem.attrib.get("path")
    if path and path.lower().endswith(('.flv', '.mp3', '.jpg', '.png', '.swf', '.xml')):
        asset_paths.append(path)

print(f"Total assets listed in XML: {len(asset_paths)}\n")

# Check which files exist and which are missing
existing_files = []
missing_files = []

for path in asset_paths:
    local_path = os.path.join(ASSETS_FOLDER, path.replace("/", os.sep))
    if os.path.isfile(local_path):
        existing_files.append(path)
    else:
        missing_files.append(path)

# Report
print("✅ Existing files:")
for f in existing_files:
    print(f"  {f}")

print("\n❌ Missing files:")
for f in missing_files:
    print(f"  {f}")

print(f"\nSummary: {len(existing_files)} exist, {len(missing_files)} missing.")