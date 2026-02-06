#!/usr/bin/env python3
import json
import os
import sys

# Definition of expected schemas for known config files
# Using tuple for nested keys: ("parent", "child")
SCHEMAS = {
    "prompt-router-config.json": {
        "required_keys": ["prompts_directory", "aliases", "rag_sources"],
        "types": {
            "prompts_directory": str,
            "aliases": dict,
            "rag_sources": dict
        }
    },
    "project-config.json": {
         "required_keys": ["project", "system"],
         "types": {
             "project": dict,
             "system": dict
         },
         "nested_checks": {
             "project": ["name", "version"]
         }
    },
     "ide-settings.json": {
         # Flexible schema, just check valid JSON
         "required_keys": [],
         "types": {}
    }
}

CONFIG_DIR = "config"

def validate_file(filename, schema):
    filepath = os.path.join(CONFIG_DIR, filename)
    if not os.path.exists(filepath):
        print(f"⚠️  Config file not found: {filename}")
        return True # Not a failure if optional

    try:
        with open(filepath, 'r') as f:
            data = json.load(f)

        # Check required keys
        for key in schema.get("required_keys", []):
            if key not in data:
                print(f"❌ {filename}: Missing required key '{key}'")
                return False

        # Check types
        for key, expected_type in schema.get("types", {}).items():
            if key in data and not isinstance(data[key], expected_type):
                print(f"❌ {filename}: Key '{key}' has wrong type. Expected {expected_type.__name__}")
                return False

        # Check nested required keys
        for parent, children in schema.get("nested_checks", {}).items():
            if parent in data and isinstance(data[parent], dict):
                for child in children:
                    if child not in data[parent]:
                         print(f"❌ {filename}: Missing required nested key '{parent}.{child}'")
                         return False

        print(f"✅ {filename}: Valid")
        return True
    except json.JSONDecodeError as e:
        print(f"❌ {filename}: Invalid JSON format - {e}")
        return False
    except Exception as e:
        print(f"❌ {filename}: Validation error - {e}")
        return False

def main():
    if not os.path.exists(CONFIG_DIR):
         print(f"❌ Config directory '{CONFIG_DIR}' not found.")
         sys.exit(1)

    all_valid = True
    for filename, schema in SCHEMAS.items():
        if failed := not validate_file(filename, schema):
             all_valid = False

    if all_valid:
        print("\nAll config files validated successfully.")
        sys.exit(0)
    else:
        print("\nSome config files failed validation.")
        sys.exit(1)

if __name__ == "__main__":
    main()
