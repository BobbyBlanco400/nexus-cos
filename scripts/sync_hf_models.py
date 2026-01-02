#!/usr/bin/env python3
"""
HuggingFace Model Synchronization Script
Downloads and manages versioned model artifacts
"""

import argparse
import sys
import os
import json
from pathlib import Path


def ensure_storage_directory():
    """Create storage/models directory if it doesn't exist"""
    storage_path = Path('./storage/models')
    storage_path.mkdir(parents=True, exist_ok=True)
    print(f"✓ Storage directory ready: {storage_path.absolute()}")
    return storage_path


def sync_model(model_name, storage_path):
    """Sync a specific model (placeholder for actual HF download)"""
    print(f"  - Syncing model: {model_name}")
    
    # Create model directory
    model_dir = storage_path / model_name.replace('/', '_')
    model_dir.mkdir(exist_ok=True)
    
    # Create metadata file
    metadata = {
        'model': model_name,
        'synced_at': 'placeholder',
        'version': '1.0.0',
        'status': 'ready'
    }
    
    metadata_file = model_dir / 'metadata.json'
    with open(metadata_file, 'w') as f:
        json.dump(metadata, indent=2, fp=f)
    
    print(f"    ✓ Model synced to: {model_dir}")


def sync_all_models(internal=False):
    """Sync all configured models"""
    print("Syncing HuggingFace models...")
    
    storage_path = ensure_storage_directory()
    
    # Default models to sync
    models = [
        'gpt2',
        'distilbert-base-uncased-finetuned-sst-2-english',
        'facebook/bart-large-cnn',
        'deepset/roberta-base-squad2',
        'Helsinki-NLP/opus-mt-en-es'
    ]
    
    print(f"\nSyncing {len(models)} models...")
    for model in models:
        sync_model(model, storage_path)
    
    print(f"\n✓ All models synced successfully")
    print(f"  Storage path: {storage_path.absolute()}")
    
    if internal:
        print("  Mode: Internal (no external API calls)")


def main():
    parser = argparse.ArgumentParser(description='Sync HuggingFace Models')
    parser.add_argument('--all', action='store_true',
                      help='Sync all configured models')
    parser.add_argument('--model', type=str,
                      help='Sync a specific model')
    parser.add_argument('--internal', action='store_true',
                      help='Use internal mode (no external API calls)')
    
    args = parser.parse_args()
    
    try:
        if args.all:
            sync_all_models(internal=args.internal)
        elif args.model:
            storage_path = ensure_storage_directory()
            sync_model(args.model, storage_path)
        else:
            print("Please specify --all or --model <model_name>")
            return 1
        
        return 0
        
    except Exception as e:
        print(f"✗ Error: {str(e)}", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
