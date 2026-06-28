#!/usr/bin/env python3
"""
通用 EPUB 解析工具 — 分析 EPUB 结构，提取目录和章节文本。

用法:
  python parse_epub.py <epub_path>

输出:
  - EPUB 的 spine 阅读顺序
  - NCX 目录条目
  - 每个内容文件的字符数、标题、开头预览
"""

import zipfile
import os
import re
import sys
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


def parse_epub(epub_path):
    if not os.path.exists(epub_path):
        print(f"ERROR: File not found: {epub_path}")
        sys.exit(1)

    with zipfile.ZipFile(epub_path) as z:
        # Find OPF file
        opf_files = [f for f in z.namelist() if f.endswith('.opf')]
        if not opf_files:
            # Try container.xml
            try:
                container = z.read('META-INF/container.xml').decode('utf-8', errors='ignore')
                opf_path = re.search(r'full-path="([^"]+)"', container).group(1)
            except Exception:
                print("ERROR: Cannot find OPF file in EPUB")
                sys.exit(1)
        else:
            opf_path = opf_files[0]

        opf_dir = os.path.dirname(opf_path)
        with z.open(opf_path) as f:
            opf_content = f.read().decode('utf-8', errors='ignore')

        # Extract spine order
        spine_ids = re.findall(r'<itemref\s+idref="([^"]+)"', opf_content)
        id_to_href = dict(re.findall(r'<item\s+[^>]*id="([^"]+)"[^>]*href="([^"]+)"', opf_content))
        # Also try reversed attribute order
        id_to_href.update(dict(re.findall(r'<item\s+[^>]*href="([^"]+)"[^>]*id="([^"]+)"', opf_content)))

        print("=== Spine order (reading order) ===")
        content_files = []
        for sid in spine_ids:
            if sid in id_to_href:
                href = id_to_href[sid]
                if href.endswith('.html') or href.endswith('.xhtml'):
                    full_path = f"{opf_dir}/{href}" if opf_dir else href
                    content_files.append(full_path)
                    print(f"  {href}")

        # Find NCX file
        ncx_files = [f for f in z.namelist() if f.endswith('.ncx')]
        if ncx_files:
            ncx_content = z.read(ncx_files[0]).decode('utf-8', errors='ignore')
            nav_points = re.findall(r'<navPoint[^>]*>.*?<navLabel>.*?<text>(.*?)</text>.*?<content src="([^"]+)"', ncx_content, re.DOTALL)
            print(f"\n=== NCX TOC entries: {len(nav_points)} ===")
            for i, (title, src) in enumerate(nav_points):
                title = re.sub(r'<[^>]+>', '', title).strip()
                print(f"  {i+1}. {title} -> {src}")

        # Analyze each content file
        print(f"\n=== Content file analysis ===")
        for cf in content_files:
            try:
                raw = z.read(cf).decode('utf-8', errors='ignore')
                extractor = TextExtractor()
                extractor.feed(raw)
                text = ''.join(extractor.text).strip()
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


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python parse_epub.py <epub_path>")
        sys.exit(1)
    parse_epub(sys.argv[1])
