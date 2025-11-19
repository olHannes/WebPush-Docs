import subprocess
import os

folders = [
    "./projects/SmartDataJobs",
    "./projects/WebPush",
    "./software/payara6/glassfish/domains/domain1/docroot/SWAC",
    "./software/payara6/glassfish/domains/domain1/docroot/WebPush-PWA",
    "./software/payara6/glassfish/domains/domain1/docroot/WebPush-Admin-Interface"
]

for folder in folders:
    print(f"\n--- Pulling in {folder} ---")
    # Wechsle in das Verzeichnis und führe git pull aus
    subprocess.run(["git", "-C", folder, "pull"], shell=False)

print("\nFertig!")
