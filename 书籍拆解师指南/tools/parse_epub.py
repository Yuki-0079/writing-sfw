import zipfile, os, re
from html.parser import HTMLParser

class TextExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.text = []
        self.skip = False
    def handle_starttag(self, tag, attrs):
        if tag in ('script', 'style'):
            self.skip = True
    def handle_endtag(self, tag):
        if tag in ('script', 'style'):
            self.skip = False
        if tag in ('p', 'br', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'tr', 'blockquote'):
            self.text.append('\n')
    def handle_data(self, data):
        if not self.skip:
            self.text.append(data.strip())

epub_path = r'C:\Opencode\writing_sfw\books\成为作家.epub'

with zipfile.ZipFile(epub_path) as z:
    # Read OPF to get spine order
    with z.open('OEBPS/content.opf') as f:
        opf_content = f.read().decode('utf-8', errors='ignore')
    
    # Extract spine items in order
    spine_ids = re.findall(r'<itemref idref="([^"]+)"', opf_content)
    id_to_href = dict(re.findall(r'<item id="([^"]+)" href="([^"]+)"', opf_content))
    
    print("=== Spine order (reading order) ===")
    content_files = []
    for sid in spine_ids:
        if sid in id_to_href:
            href = id_to_href[sid]
            if href.endswith('.html'):
                content_files.append(f'OEBPS/{href}')
                print(f"  {href}")
    
    # Read NCX for TOC entries
    ncx_content = z.read('OEBPS/toc.ncx').decode('utf-8', errors='ignore')
    
    # Try different NCX formats
    nav_points = re.findall(r'<navPoint[^>]*>.*?<navLabel>.*?<text>(.*?)</text>.*?<content src="([^"]+)"', ncx_content, re.DOTALL)
    print(f"\n=== NCX TOC entries: {len(nav_points)} ===")
    for i, (title, src) in enumerate(nav_points):
        print(f"  {i+1}. {title} -> {src}")
    
    # Also try to find headings in the full NCX
    labels = re.findall(r'<text>(.*?)</text>', ncx_content)
    print(f"\n=== All NCX labels ({len(labels)}) ===")
    for i, l in enumerate(labels):
        print(f"  {i+1}. {l}")
    
    # Read each content file and extract headings
    print(f"\n=== Content file analysis ===")
    for cf in content_files:
        try:
            raw = z.read(cf).decode('utf-8', errors='ignore')
            extractor = TextExtractor()
            extractor.feed(raw)
            text = ''.join(extractor.text).strip()
            # Find headings
            h_tags = re.findall(r'<h[1-6][^>]*>(.*?)</h[1-6]>', raw, re.DOTALL | re.IGNORECASE)
            h_texts = [re.sub(r'<[^>]+>', '', h).strip() for h in h_tags]
            h_nonempty = [h for h in h_texts if h]
            first_words = text[:80].replace('\n', ' ').strip()
            print(f"\n  {cf} ({len(text)} chars)")
            if h_nonempty:
                print(f"  Headings: {' | '.join(h_nonempty[:5])}")
            print(f"  Starts: {first_words}...")
        except Exception as e:
            print(f"\n  {cf}: ERROR {e}")
