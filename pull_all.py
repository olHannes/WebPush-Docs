import subprocess
import os

BASE = r"C:\SmartDeveloper"   # fester Hauptpfad

folders = [
    os.path.join(BASE, r"projects\SmartDataJobs"),
    os.path.join(BASE, r"projects\WebPush"),
    os.path.join(BASE, r"projects\SmartData"),
    os.path.join(BASE, r"projects\SmartDataLyser"),
    os.path.join(BASE, r"software\payara6\glassfish\domains\domain1\docroot\SWAC"),
    os.path.join(BASE, r"software\payara6\glassfish\domains\domain1\docroot\WebPush-PWA"),
    os.path.join(BASE, r"software\payara6\glassfish\domains\domain1\docroot\WebPush-Admin-Interface")
]

for folder in folders:
    print(f"\n--- Pulling in {folder} ---")
    subprocess.run(["git", "-C", folder, "pull"], shell=False)

print("\nFertig!")
