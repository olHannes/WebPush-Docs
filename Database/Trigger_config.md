# Trigger-Konfiguration (JSONB in PostgreSQL)



**Verbesserte Idee**:

Jeder Trigger in der Tabelle besitzt ein config Feld. Dieses wird im Backend ausgewertet, um zu entscheiden, ob eine Nachricht gesendet werden soll. 
```json
{
  "when": {
    "schedule": {
      "type": "recurring",
      "frequency": "daily",
      "time": "09:00"
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
  },
  "action": { "notification_id": 123 }
}
```

**wöchentliche Datenabhängige Erinnerung**
```json
{
  "when": {
    "schedule": {
      "type": "recurring",
      "frequency": "weekly",
      "days_of_week": ["monday"],
      "time": "09:00"
    },
    "conditions": [
      { "type": "data_threshold", "sensor_id": "2.5pm", "operator": ">", "threshold": 35 }
    ]
  },
  "action": { "notification_id": 321 }
}
```

**streak reminder**
```json
{
  "when": {
    "schedule": { "type": "daily", "time": "18:00" },
    "conditions": [
      { 
        "type": "streak_check", 
        "group_id": "Pi01", 
        "missing_activity_for": "24h" 
      }
    ]
  },
  "action": { "notification_id": 777 }
}
```

**Datenbasierter Trigger**
```json
{
  "when": {
    "conditions": [
      {
        "type": "data_count",
        "group_id": "Pi01",
        "time_range": "today",
        "operator": ">=",
        "threshold": 100
      }
    ]
  },
  "action": {
    "notification_id": 42
  }
}
```



## **Achievement**

Achievements sind ähnlich aufgebaut. Sie haben eine config (JSONB) die ähnlich wie zu den Triggern aussagt, ob eine Gruppe diese Bedingung erfüllt hat.

```json
{
  "when": {
    "conditions": [
      {
        "group_id": "Pi01",
        "data_field": "sensor_xy",
        "time_range": "total",
        "operator": ">=",
        "threshold": 100
      }
    ]
  }
}
```
