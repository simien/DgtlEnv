#!/usr/bin/env python3
"""
Simple RAG Retriever (Standard Library Only)

Retrieves relevant text snippets from loose files based on a query.
Uses a simplified TF-IDF scoring mechanism.

Usage:
    python3 rag_retriever.py --query "some query" --sources "/path/to/docs,/path/to/notes" --top-k 3
"""

import os
import sys
import argparse
import math
import re
from collections import Counter
from pathlib import Path

# --- Configuration ---
EXTENSIONS = {'.md', '.txt', '.sh', '.py', '.json'}
STOP_WORDS = {
    'a', 'an', 'the', 'and', 'or', 'but', 'if', 'then', 'else', 'when',
    'at', 'by', 'for', 'from', 'in', 'into', 'of', 'off', 'on', 'onto',
    'to', 'with', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'i', 'you', 'he', 'she', 'it', 'we', 'they', 'this', 'that',
    'what', 'which', 'who', 'whom', 'whose', 'how', 'where', 'why'
}

def tokenize(text):
    """Simple tokenizer: lowercase, remove non-alphanumeric, split."""
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', ' ', text)
    tokens = text.split()
    return [t for t in tokens if t not in STOP_WORDS]

def compute_tf(tokens):
    """Compute Term Frequency (TF)."""
    tf = Counter(tokens)
    total = len(tokens)
    if total == 0:
        return {}
    return {t: count / total for t, count in tf.items()}

def compute_idf(documents):
    """Compute Inverse Document Frequency (IDF)."""
    N = len(documents)
    if N == 0:
        return {}

    idf = {}
    all_tokens = set()
    for doc in documents:
        all_tokens.update(doc['tokens'])

    for token in all_tokens:
        containing_docs = sum(1 for doc in documents if token in doc['tokens'])
        idf[token] = math.log10(N / (1 + containing_docs))

    return idf

def score_document(query_tokens, doc_tokens, idf):
    """Score a document against a query using TF-IDF."""
    if not doc_tokens or not query_tokens:
        return 0.0

    tf = compute_tf(doc_tokens)
    score = 0.0

    for token in query_tokens:
        if token in tf:
            # TF-IDF score for this token in this document
            token_score = tf[token] * idf.get(token, 0.0)
            score += token_score

    return score

def load_documents(sources):
    """Load documents from source directories."""
    documents = []

    for source in sources:
        path = Path(source)
        if not path.exists():
            continue

        if path.is_file():
            files = [path]
        else:
            files = [p for p in path.rglob('*') if p.suffix in EXTENSIONS]

        for file_path in files:
            try:
                # Skip large files > 1MB
                if file_path.stat().st_size > 1024 * 1024:
                    continue

                text = file_path.read_text(errors='ignore')
                tokens = tokenize(text)
                if tokens:
                   documents.append({
                       'path': str(file_path),
                       'content': text,
                       'tokens': set(tokens) # Use set for faster presence check
                   })
            except Exception as e:
                # Silently ignore read errors
                pass

    return documents

def main():
    parser = argparse.ArgumentParser(description='Simple RAG Retriever')
    parser.add_argument('--query', required=True, help='Search query')
    parser.add_argument('--sources', required=True, help='Comma-separated source paths')
    parser.add_argument('--top-k', type=int, default=3, help='Number of results to return')

    args = parser.parse_args()

    sources = [s.strip() for s in args.sources.split(',')]
    query_tokens = tokenize(args.query)

    if not query_tokens:
        return

    documents = load_documents(sources)
    if not documents:
        return

    # Precompute IDF
    idf = compute_idf(documents)

    # Score documents
    results = []
    for doc in documents:
        # Re-tokenize content as list for TF calculation (was set in load_documents, need list logic if we want real TF, but for this simple version set presence is okay, or we reuse tokenizer)
        # To be precise, let's re-tokenize or store list. Storing list is better.
        # Refactoring 'load_documents' to store list:
        # Actually simplest to just re-tokenize on demand or store list.
        # Let's just fix load_documents logic inline here for simplicity
        pass

    # Correcting logic: Load documents needs to store token list for TF
    documents = [] # Reset
    for source in sources:
        path = Path(source)
        if not path.exists(): continue
        files = [path] if path.is_file() else [p for p in path.rglob('*') if p.suffix in EXTENSIONS]
        for file_path in files:
            try:
                if file_path.stat().st_size > 1024 * 1024: continue
                text = file_path.read_text(errors='ignore')
                tokens = tokenize(text)
                if tokens:
                    documents.append({'path': str(file_path), 'content': text, 'tokens': tokens, 'unique_tokens': set(tokens)})
            except: pass

    if not documents: return

    # IDF again
    idf = {}
    N = len(documents)
    all_tokens = set()
    for doc in documents: all_tokens.update(doc['unique_tokens'])
    for token in all_tokens:
        count = sum(1 for doc in documents if token in doc['unique_tokens'])
        idf[token] = math.log10(N / (1 + count))

    # Score
    scored_docs = []
    for doc in documents:
        score = score_document(query_tokens, doc['tokens'], idf)
        if score > 0:
            scored_docs.append((score, doc))

    # Sort and return
    scored_docs.sort(key=lambda x: x[0], reverse=True)

    top_docs = scored_docs[:args.top_k]

    if not top_docs:
        print("No relevant context found.")
    else:
        print(f"found {len(top_docs)} relevant context sources:\n")
        for score, doc in top_docs:
            print(f"--- SOURCE: {doc['path']} (Score: {score:.4f}) ---")
            print(doc['content'][:1000].replace('\n', ' ')) # Preview
            print("...\n")

if __name__ == "__main__":
    main()
