#!/usr/bin/env python3
"""
通用 EPUB 章节提取工具 — 从 EPUB 中提取指定章节的纯文本。

用法:
  python extract_chapters.py <epub_path> [chapter_file1 chapter_file2 ...]

如果不指定 chapter_file，则提取所有 HTML 内容文件。

输出:
  每个章节的纯文本，以分隔线标记，包含字符数统计。
"""

import zipfile
import re
import sys
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


def extract_chapters(epub_path, chapter_files=None):
    with zipfile.ZipFile(epub_path) as z:
        if chapter_files is None:
            # Auto-discover content files from OPF
            opf_files = [f for f in z.namelist() if f.endswith('.opf')]
            if opf_files:
                opf_content = z.read(opf_files[0]).decode('utf-8', errors='ignore')
                spine_ids = re.findall(r'<itemref\s+idref="([^"]+)"', opf_content)
                id_to_href = dict(re.findall(r'<item\s+[^>]*id="([^"]+)"[^>]*href="([^"]+)"', opf_content))
                id_to_href.update(dict(re.findall(r'<item\s+[^>]*href="([^"]+)"[^>]*id="([^"]+)"', opf_content)))
                opf_dir = os.path.dirname(opf_files[0])
                chapter_files = []
                for sid in spine_ids:
                    if sid in id_to_href:
                        href = id_to_href[sid]
                        if href.endswith('.html') or href.endswith('.xhtml'):
                            full_path = f"{opf_dir}/{href}" if opf_dir else href
                            chapter_files.append(full_path)
            else:
                chapter_files = [f for f in z.namelist() if f.endswith('.html') or f.endswith('.xhtml')]

        for cf in chapter_files:
            try:
                raw = z.read(cf).decode('utf-8', errors='ignore')
                extractor = CleanExtractor()
                extractor.feed(raw)
                text = ''.join(extractor.text)
                text = re.sub(r'\n{3,}', '\n\n', text).strip()
                print(f"\n{'='*60}")
                print(f"=== {cf} ===")
                print(f"{'='*60}")
                print(f"({len(text)} chars)")
                print(text)
            except Exception as e:
                print(f"\n{'='*60}")
                print(f"=== {cf} === ERROR: {e}")
                print(f"{'='*60}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python extract_chapters.py <epub_path> [chapter_file1 chapter_file2 ...]")
        sys.exit(1)

    epub_path = sys.argv[1]
    chapter_files = sys.argv[2:] if len(sys.argv) > 2 else None
    extract_chapters(epub_path, chapter_files)
