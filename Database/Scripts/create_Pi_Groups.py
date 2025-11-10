import requests

ObservedObjects_URL = "http://localhost:8080/SmartDataAirquality/smartdata/records/tbl_observedobject?storage=smartmonitoring"

SmartData_URL = "http://localhost:8080/SmartDataAirquality/smartdata/records/groups?storage=gamification"

def postGroup(name, table):
    payload = {
        "name": name,
        "data_table": table
    }
    try:
        response = requests.post(
            SmartData_URL,
            json=payload,
            timeout=5
        )
        if response.status_code==409:
            print(f"Gruppe '{name}' existiert bereits")
            return
        print(f"Gruppe '{name}' angelegt")
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"konnte Gruppe '{name}' nicht anlegen: {e}")



try:
    response = requests.get(ObservedObjects_URL, timeout=5)
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
    postGroup(name, collection)