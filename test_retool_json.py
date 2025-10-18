#!/usr/bin/env python3
"""
Test script to validate retool_admin_dashboard.json structure.
Ensures the JSON file is syntactically valid for Retool import.
"""

import json
import sys

def test_retool_dashboard_json():
    """Validate the retool_admin_dashboard.json file structure."""
    
    filename = 'retool_admin_dashboard.json'
    
    try:
        with open(filename, 'r') as f:
            content = f.read()
        
        # Test 1: Valid JSON parsing
        print(f"Test 1: Parsing {filename}...")
        data = json.loads(content)
        print("✓ JSON is valid and parseable")
        
        # Test 2: Required top-level structure
        print("\nTest 2: Checking top-level structure...")
        required_keys = ['uuid', 'page', 'modules']
        for key in required_keys:
            assert key in data, f"Missing required key: {key}"
            print(f"✓ Has '{key}' key")
        
        # Test 3: UUID format
        print("\nTest 3: Validating UUID...")
        assert isinstance(data['uuid'], str), "UUID must be a string"
        assert len(data['uuid']) > 0, "UUID cannot be empty"
        print(f"✓ UUID is valid: {data['uuid'][:20]}...")
        
        # Test 4: Page structure
        print("\nTest 4: Checking page structure...")
        assert isinstance(data['page'], dict), "page must be an object"
        assert 'id' in data['page'], "page must have 'id'"
        assert 'data' in data['page'], "page must have 'data'"
        print("✓ Page structure is valid")
        
        # Test 5: Page data and appState
        print("\nTest 5: Validating page.data.appState...")
        page_data = data['page']['data']
        assert 'appState' in page_data, "page.data must have 'appState'"
        assert isinstance(page_data['appState'], str), "appState must be a string"
        assert len(page_data['appState']) > 0, "appState cannot be empty"
        print(f"✓ appState is valid (length: {len(page_data['appState'])} chars)")
        
        # Test 6: changesRecord exists
        print("\nTest 6: Checking changesRecord...")
        assert 'changesRecord' in data['page'], "page must have 'changesRecord'"
        print("✓ changesRecord exists")
        
        # Test 7: Verify appState string has proper closing before changesRecord
        print("\nTest 7: Verifying appState string closure...")
        # The pattern should be: "appState":"..."},"changesRecord"
        if '"},"changesRecord"' in content:
            print("✓ appState string is properly closed before changesRecord")
        else:
            print("✗ Warning: Unexpected pattern around appState closure")
            return False
        
        # Test 8: Balanced braces
        print("\nTest 8: Checking brace balance...")
        open_braces = content.count('{')
        close_braces = content.count('}')
        assert open_braces == close_braces, f"Unbalanced braces: {open_braces} open, {close_braces} close"
        print(f"✓ Braces are balanced ({open_braces} pairs)")
        
        # Test 9: modules structure
        print("\nTest 9: Validating modules...")
        assert isinstance(data['modules'], dict), "modules must be an object"
        print("✓ modules structure is valid")
        
        print("\n" + "="*60)
        print("ALL TESTS PASSED!")
        print("retool_admin_dashboard.json is valid for Retool import.")
        print("="*60)
        return True
        
    except FileNotFoundError:
        print(f"✗ Error: {filename} not found")
        return False
    except json.JSONDecodeError as e:
        print(f"✗ Error: Invalid JSON - {e}")
        return False
    except AssertionError as e:
        print(f"✗ Error: Validation failed - {e}")
        return False
    except Exception as e:
        print(f"✗ Unexpected error: {e}")
        return False

if __name__ == '__main__':
    success = test_retool_dashboard_json()
    sys.exit(0 if success else 1)
