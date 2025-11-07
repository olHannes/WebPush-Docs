# Trigger-Konfiguration (JSONB in PostgreSQL)


Jeder Trigger in der Tabelle besitzt ein config Feld. Dieses wird im Backend ausgewertet, um zu entscheiden, ob eine Nachricht gesendet werden soll.
Dabei ist der Aufbau immer gleich:
- Es gibt ein schedule feld, welches Zeitbedingte Auslöser beschreibt
- eine Liste an Conditions, welche Datenbasierte Auslöser behandeln

-> Über zwei Views kann man alle (nicht-) zeitlich gebundenen Trigger auslesen und im Backend verarbeiten

```json
{
  "when": {
    "schedule": {
      "type": "recurring",
      "cron": "* * * * *"
    },
    "conditions": [
      {
        "type": "data_threshold",
        "sensor_id": "raspi_23_temp",
        "operator": ">",
        "threshold": 35.0,
        "duration": "5m"
      },
      {
        "type": "streak_check",
        "group_id": "Pi01",
        "streak_target": 7,
        "last_activity_before": "24h"
      }
    ]
  }
}
```
# Anwendungsfälle
**Einmaliger Reminder**
```json
{
  "when": {
    "schedule": { "type": "once", "datetime": "2025-11-01T09:00:00Z" }
  }
}
```

**wöchentliche Datenabhängige Erinnerung**
```json
{
  "when": {
    "schedule": {
      "type": "recurring",
      "cron": "0 20 * * FRI" //jeden Freitag um 20:00
    },
    "conditions": [
      { "type": "data_threshold", "sensor_id": "2.5pm", "operator": ">", "threshold": 35 }
    ]
  }
}
```