import pandas as pd
import requests
import json

PUT_URL = "http://localhost:8080/SmartDataAirquality/smartdata/records/group/9?storage=gamification"

body = {"last_activity": "2023-08-29T08:27:41.497"}
payload = json.dumps(body)

# Send PUT request to change last_activity of group 9
headers = {'Content-Type': 'application/json'}
response = requests.put(PUT_URL, data=payload, headers=headers)
print(f"Status code: {response.status_code}")
print(f"Response: {response.text}")


POST_URL_DATA = "http://localhost:8080/SmartDataAirquality/smartdata/records/sensor_b827eb0fae5c?storage=smartmonitoring"
CSV_PATH_DATA = "./sensor_b827eb0fae5c_202601051328.csv"

# Read CSV
df = pd.read_csv(
    CSV_PATH_DATA,
    sep=",",
    quotechar='"',
    decimal='.',
    keep_default_na=False,
    na_filter=False
)
# Convert DataFrame to list of dicts (records)
data = df.to_dict(orient="records")

payload = json.dumps(data)

# Send POST request with sensor data
headers = {'Content-Type': 'application/json'}
response = requests.post(POST_URL_DATA, data=payload, headers=headers)
print(f"Status code: {response.status_code}")
print(f"Response: {response.text}")

POST_URL_TRAVEL_TYPES = "http://localhost:8080/SmartDataAirquality/smartdata/records/means_of_travel_join_process?storage=smartmonitoring"
CSV_PATH_TRAVEL_TYPES = "./travel_type_data_for_sensor_b827eb0fae5c.csv"

# Read CSV for travel types
df_travel_types = pd.read_csv(
    CSV_PATH_TRAVEL_TYPES,
    sep=",",
    quotechar='"'
)
# Convert DataFrame to list of dicts (records)
data = df_travel_types.to_dict(orient="records")

payload = json.dumps(data)

# Send POST request with sensor data
headers = {'Content-Type': 'application/json'}
response = requests.post(POST_URL_TRAVEL_TYPES, data=payload, headers=headers)
print(f"Status code: {response.status_code}")
print(f"Response: {response.text}")


# Send POST request to mark the data upload as finished
headers = {'Content-Type': 'application/json'}
response = requests.post(POST_URL_DATA, data=json.dumps({"finished": True}), headers=headers)
print(f"Status code: {response.status_code}")
print(f"Response: {response.text}")