# 🧩 Trigger-Konfiguration (JSONB in PostgreSQL)

Jeder Trigger in der Tabelle `triggers` besitzt:
- ein Feld `type` (`ENUM`): definiert den Typ des Auslösers  
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
- Nach Ausführung kann `active = false` gesetzt werden.  

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