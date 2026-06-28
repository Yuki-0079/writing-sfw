# Installation Guide

## 前置依赖

### 1. close-reading-protocol skill

本 skill 依赖 `close-reading-protocol` 作为前置阅读协议。确保已安装：

```
~/.workbuddy/skills/close-reading-protocol/SKILL.md
```

如未安装，请先安装 close-reading-protocol。

### 2. Python（可选，用于 EPUB 提取脚本）

EPUB 提取脚本使用 Python 标准库，无需额外依赖：

```bash
python scripts/parse_epub.py book.epub
python scripts/extract_chapters.py book.epub
```

如需 OCR 扫描版 PDF：

```bash
pip install pytesseract pillow pdf2image
# 并安装 Tesseract OCR 引擎 + 中文语言包
```

## 安装方式

### WorkBuddy Desktop

```bash
# 复制到用户级 skill 目录（所有项目可用）
cp -r book-deconstruction ~/.workbuddy/skills/
```

### 验证安装

```bash
# 检查文件完整性
ls ~/.workbuddy/skills/book-deconstruction/SKILL.md
ls ~/.workbuddy/skills/book-deconstruction/references/chapter-extraction.md
ls ~/.workbuddy/skills/book-deconstruction/scripts/parse_epub.py
```

## 使用方式

在对话中触发：

```
加载 book-deconstruction skill，我要拆解一本书。
```

或指定模式：

```
加载 book-deconstruction skill，模式 A，目标：《书名》
加载 book-deconstruction skill，模式 B，目标：mckee-story-analyzer
加载 book-deconstruction skill，模式 C，组装主 skill
```
