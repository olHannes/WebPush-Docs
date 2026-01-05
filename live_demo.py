import pandas as pd
import requests
import json

CSV_PATH = "./sensor_b827eb0fae5c_202601051328.csv"
POST_URL = "http://localhost:8080/SmartDataAirquality/smartdata/records/sensor_b827eb0fae5c?storage=smartmonitoring"

# Read CSV
df = pd.read_csv(
    CSV_PATH,
    sep=",",
    quotechar='"',
    decimal='.',
    keep_default_na=False,
    na_filter=False
)
# Convert DataFrame to list of dicts (records)
data = df.to_dict(orient="records")

# Build the custom JSON structure: list of dicts, then 'finished': true
# payload = {"data": data.copy(), "finished": True}

# print("Prepared JSON data:")
# print(json.dumps(payload))

# Send POST request
headers = {'Content-Type': 'application/json'}
response = requests.post(POST_URL, data=json.dumps(data), headers=headers)

print(f"Status code: {response.status_code}")
print(f"Response: {response.text}")