import requests

API_URL = "http://localhost:8080/SmartDataAirquality/smartdata/records/tbl_observedobject?storage=smartmonitoring"

try:
    response = requests.get(API_URL, timeout=5)
    response.raise_for_status()
except requests.RequestExeption as e:
    raise SystemExit(f"API request failed: {e}")

data = response.json()
records = data.get("records")

if not isinstance(records, list):
    raise ValueError("Expected a JSON array from API,")

for entry in records:
    if not isinstance(entry, dict):
        continue
    if entry.get("icon") != "SENSORpi":
        continue
    name = entry.get("name")
    collection = entry.get("data_collection")
    if not name or not collection:
        print("Warnung: der Eintrag hat keinen namen / collection -> skip")
        continue
    formatted_post = f"RECORDS_{collection.upper()}_SMARTMONITORING_POST_url=http://localhost:8080/WebPush/smarttemplate/admin/webhook"
    formatted_put = f"RECORDS_{collection.upper()}_SMARTMONITORING_PUT_url=http://localhost:8080/WebPush/smarttemplate/admin/webhook"
    formatted_delete = f"RECORDS_{collection.upper()}_SMARTMONITORING_DELETE_url=http://localhost:8080/WebPush/smarttemplate/admin/webhook"
    
    print(f"# Mirroring of: {name}")
    print(formatted_post)
    print(formatted_put)
    #print(formatted_delete)
    print("\n")