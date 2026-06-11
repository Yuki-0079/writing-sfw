import zipfile, re, json, sys
from html.parser import HTMLParser

class CleanExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.text = []
        self.skip = False
    def handle_starttag(self, tag, attrs):
        if tag in ('script', 'style'):
            self.skip = True
        if tag in ('p', 'br', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'blockquote', 'tr'):
            self.text.append('\n')
    def handle_endtag(self, tag):
        if tag in ('script', 'style'):
            self.skip = False
    def handle_data(self, data):
        if not self.skip:
            self.text.append(data.strip())

epub_path = r'C:\Opencode\writing_sfw\books\成为作家.epub'
chapter_files = sys.argv[1:] if len(sys.argv) > 1 else [
    'OEBPS/text00004.html', 'OEBPS/text00005.html',
    'OEBPS/text00006.html', 'OEBPS/text00007.html',
    'OEBPS/text00008.html', 'OEBPS/text00009.html',
    'OEBPS/text00010.html', 'OEBPS/text00011.html',
    'OEBPS/text00012.html', 'OEBPS/text00013.html',
    'OEBPS/text00014.html', 'OEBPS/text00015.html',
    'OEBPS/text00016.html', 'OEBPS/text00017.html',
    'OEBPS/text00018.html', 'OEBPS/text00019.html',
    'OEBPS/text00020.html', 'OEBPS/text00021.html',
    'OEBPS/text00022.html', 'OEBPS/text00023.html',
]

with zipfile.ZipFile(epub_path) as z:
    for cf in chapter_files:
        raw = z.read(cf).decode('utf-8', errors='ignore')
        extractor = CleanExtractor()
        extractor.feed(raw)
        text = ''.join(extractor.text)
        text = re.sub(r'\n{3,}', '\n\n', text).strip()
        print(f"\n{'='*60}")
        print(f"=== {cf} ===")
        print(f"{'='*60}")
        print(f"({len(text)} 字符)")
        print(text)
