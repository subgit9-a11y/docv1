import urllib.request
import urllib.error
import json

def test_endpoint(name, url, method="GET", headers=None, data=None):
    if headers is None:
        headers = {}
    
    print(f"Testing {name} [{method}] {url}...")
    try:
        req = urllib.request.Request(url, headers=headers, method=method)
        if data:
            req.data = json.dumps(data).encode('utf-8')
            req.add_header('Content-Type', 'application/json')
            
        with urllib.request.urlopen(req, timeout=10) as response:
            status = response.getcode()
            body = response.read().decode('utf-8')
            print(f"✅ SUCCESS: {status}")
            return True, status, body
    except urllib.error.HTTPError as e:
        print(f"❌ HTTP ERROR: {e.code} - {e.reason}")
        return False, e.code, e.read().decode('utf-8')
    except Exception as e:
        print(f"❌ FAILED: {str(e)}")
        return False, None, str(e)

if __name__ == "__main__":
    print("========================================")
    print("PHASE 2: API OPERATIONAL VALIDATION")
    print("========================================\n")
    
    # We will test the known public Astra endpoint verified in Phase 1
    # from the artifact: backend_missing_endpoints.md
    
    endpoints = [
        ("Astra Video Token Generator", "https://astra.ayureze.in/api/v1/video/token?channel=test_call"),
        ("AyurEze Staging API Base", "https://staging-api.ayureze.in"),
        ("Astra Staging API Base", "https://staging-astra.ayureze.in"),
    ]
    
    for name, url in endpoints:
        test_endpoint(name, url)
        print("-" * 40)
        
    print("\nAPI Health Check Complete.")
