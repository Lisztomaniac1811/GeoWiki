import os
import re
import requests
import xml.etree.ElementTree as ET
from urllib.parse import urljoin

# --- CONFIGURATION ---
XML_FILE = 'batess2_config.xml'
# This is the base URL from the time Season 2 was active (approx 2014-2015)
BASE_URL = "http://www.batesmotel.com/" 
# Format: https://web.archive.org/web/[TIMESTAMP]id_/[URL]
# Using 'id_' ensures you get the raw file, not the Wayback wrapper.
WAYBACK_PREFIX = "https://web.archive.org/web/20140501000000id_/"

def download_file(relative_path):
    if not relative_path or not isinstance(relative_path, str):
        return

    # Clean the path (remove leading slashes or white space)
    relative_path = relative_path.strip().lstrip('/')
    
    # Exclude external links that aren't assets
    if relative_path.startswith('http'):
        return

    # Create local directory structure
    local_path = os.path.join('downloaded_assets', relative_path)
    local_dir = os.path.dirname(local_path)
    if not os.path.exists(local_dir):
        os.makedirs(local_dir)

    # Construct Wayback URL
    full_url = urljoin(BASE_URL, relative_path)
    wayback_url = WAYBACK_PREFIX + full_url

    # Download
    if os.path.exists(local_path):
        print(f"Skipping (exists): {relative_path}")
        return

    try:
        print(f"Downloading: {relative_path}...")
        response = requests.get(wayback_url, timeout=10)
        if response.status_code == 200:
            with open(local_path, 'wb') as f:
                f.write(response.content)
        else:
            print(f"FAILED (Status {response.status_code}): {relative_path}")
    except Exception as e:
        print(f"ERROR downloading {relative_path}: {e}")

def main():
    if not os.path.exists(XML_FILE):
        print(f"Could not find {XML_FILE}")
        return

    tree = ET.parse(XML_FILE)
    root = tree.getroot()

    # We want to find every string that looks like a file path
    # Scanning attributes: path, assetPath, largeViewPath
    # Scanning tag text: TEXTURE, LARGEVIEWASSET, SOUND
    
    paths = set()

    # 1. Search all tags for specific attributes
    for el in root.iter():
        for attr in ['path', 'assetPath', 'largeViewPath', 'up', 'over']:
            val = el.get(attr)
            if val and ('.' in val): # Check if it looks like a filename
                paths.add(val)
        
        # 2. Search tag text (for <TEXTURE> or <SOUND> tags)
        if el.text and ('.' in el.text) and ('assets/' in el.text):
            # Clean up potential CDATA or whitespace
            clean_text = el.text.strip()
            paths.add(clean_text)

    print(f"Found {len(paths)} unique assets. Starting download...")

    for p in sorted(paths):
        download_file(p)

    print("\nProcess complete. Check the 'downloaded_assets' folder.")

if __name__ == "__main__":
    main()