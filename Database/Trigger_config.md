# Trigger-Konfiguration (JSONB in PostgreSQL)

Jeder Trigger in der Tabelle `triggers` besitzt:
- ein Feld `type` (`Text`): definiert den Typ des Auslösers  
- ein Feld `config` (`JSONB`): enthält die Parameter (siehe unten)  
- optionale Felder `active` & `last_fired_at` für Steuerung und Logging  

---

## **Trigger Type: `time_once`**
Einmaliger, zeitbasierter Auslöser zu einem bestimmten Zeitpunkt.

```json
{
  "datetime": "2025-11-01T09:00:00Z"
}
```

**Beschreibung:**
- Wird zu dem angegebenen Zeitpunkt ausgelöst.  

---

## **Trigger Type: `time_recurring`**
Wiederkehrender zeitbasierter Auslöser (z. B. täglich, wöchentlich).

```json
{
  "frequency": "weekly",
  "days_of_week": ["monday", "thursday"],
  "time": "09:00"
}
```

**Beschreibung:**
- Definiert periodische Trigger, z. B. immer montags und donnerstags um 9 Uhr.  
- Für tägliche Trigger: `"frequency": "daily"` und `"time": "09:00"`.  
- Optional erweiterbar um `"end_date"` oder `"repeat_count"`.  

---

## **Trigger Type: `data_threshold`**
Datenabhängiger Auslöser – wird aktiv, wenn ein Sensorwert einen Grenzwert überschreitet.

```json
{
  "sensor_id": "raspi_23_temp",
  "operator": ">",
  "threshold": 35.0,
  "unit": "°C",
  "duration": "5m"
}
```

**Beschreibung:**
- Der Server oder ein Worker prüft regelmäßig Sensordaten.  
- Wird der Grenzwert länger als `"duration"` überschritten, löst der Trigger aus.  

---

## **Trigger Type: `streak_reminder`**
Gamification-Auslöser zur Erinnerung an tägliche/wöchentliche Aktivität („Streak“).

```json
{
  "group_id": "Pi01",
  "streak_target": 7,
  "last_activity_before": "24h"
}
```

**Beschreibung:**
- Wird ausgelöst, wenn eine Gruppe länger als `last_activity_before` inaktiv sind.  
- Typischer Einsatz: Erinnerungen an tägliche Daten-Uploads oder Messungen.  

---

## Verbesserte Idee
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
  },
  "action": {
    "notification_id": 123,
    "delay": "0s"
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