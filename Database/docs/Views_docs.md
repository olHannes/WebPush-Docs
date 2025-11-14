# Views Dokumentation
*Diese Datei beschreibt alle erstellten Views der Datenbank Smartmonitoring_airquality.gamification. Es soll außerdem als Hilfe bei der Entwicklung des Frontend's dienen*
> Jeder Eintrag hier sollte aus dem SQL-Script und einer dazugehörigen Beschreibung / Erklärung bestehen. Die URL beschreibt außerdem den SmartData Zugriff.

---
## Filter
**Eine SmartData URL lässt sich direkt mit Filtern ergänzen:**

**Aufbau**: 

`https://localhost:8181/SmartDataAirquality/smartdata/records/`+`<tablename/view>`+`?storage=gamification`+`&filter=`+`<datafield>`+`,eq,`+`<value>`

**Beispiel**; *Alle Memeber einer spezifischen Gruppe*:

*https://localhost:8181/SmartDataAirquality/smartdata/records/view_group_members?storage=gamification&filter=group_id,eq,1*

---



## Trigger
### Zeitbasierte Trigger
```sql
CREATE OR REPLACE VIEW view_triggers_with_schedule AS
SELECT
    t.id AS trigger_id,
    t.description,
    t.active,
    t.last_triggered_at,
    t.cron,
    t.time_once,
    json_agg(
        json_build_object(
            'condition_id', c.id,
            'data_field', c.data_field,
            'operator', c.operator,
            'threshold', c.threshold
        )
        ORDER BY c.id
    ) AS conditions
FROM Triggers t
JOIN Trigger_Conditions tc ON t.id = tc.trigger_id
JOIN Condition c ON c.id = tc.condition_id
WHERE t.active = TRUE
  AND (t.cron IS NOT NULL OR t.time_once IS NOT NULL)
GROUP BY
    t.id, t.description, t.active, t.last_triggered_at, t.cron, t.time_once;
```
> Der View `view_triggers_with_schedule` liefert alle Trigger, welche zeitbasiert arbeiten. *Die Datenbasierten conditions müssen vor dem Senden trotzdem geprüft werden.*

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_triggers_with_schedule?storage=gamification*


### Datenbasierte Trigger
```sql
CREATE OR REPLACE VIEW view_triggers_without_schedule AS
SELECT
    t.id AS trigger_id,
    t.description,
    t.active,
    t.last_triggered_at,
    t.cron,
    t.time_once,
    json_agg(
        json_build_object(
            'condition_id', c.id,
            'data_field', c.data_field,
            'operator', c.operator,
            'threshold', c.threshold
        )
        ORDER BY c.id
    ) AS conditions
FROM Triggers t
JOIN Trigger_Conditions tc ON t.id = tc.trigger_id
JOIN Condition c ON c.id = tc.condition_id
WHERE t.active = TRUE
  AND (t.cron IS NULL AND t.time_once IS NULL)
GROUP BY
    t.id, t.description, t.active, t.last_triggered_at, t.cron, t.time_once;
```
> Der View `view_triggers_without_schedule` liefert alle Trigger, welche rein datenbasiert arbeiten. *Die Liste an conditions müssen alle erfüllt sein.*

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_triggers_without_schedule?storage=gamification*

## Leaderboard
```sql
CREATE OR REPLACE VIEW view_leaderboard AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    g.level,
    g.xp,
    g.streak,
    RANK() OVER (ORDER BY g.xp DESC, g.level DESC) AS rank_xp
FROM gamification.Groups g
ORDER BY g.xp DESC;
```
> Der View `view_leaderboard` lädt eine sortierte Liste aller Gruppen. Dabei wird absteigend nach dem xp-Wert (*bei Gleichstand zusätzlich nach dem Level*) sortiert.

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_leaderboard?storage=gamification*

## Group-Achievements
```sql
CREATE OR REPLACE VIEW view_group_achievements AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    a.id AS achievement_id,
    a.title AS achievement_title,
    a.description AS achievement_description,
    a.image_url AS achievement_image_url,
    a.reward_xp AS achievement_reward_xp,
    a.trigger_id
FROM Group_Achievement ga
JOIN Groups g ON ga.group_id = g.id
JOIN Achievements a ON ga.achievement_id = a.id;
```
> Dieser View (`view_group_achievements`) listet alle Gruppen mit den vergebenen Achievements auf (Auflösung der NxM-Tabelle).

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_group_achievements?storage=gamification*

## Group-Member
```sql
CREATE OR REPLACE VIEW view_group_members AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    g.level,
    g.xp,
    g.streak,
    m.id AS member_id,
    m.name AS member_name,
    m.endpoint AS member_endpoint
FROM gamification.Group_Member gm
JOIN gamification.Groups g ON gm.group_id = g.id
JOIN gamification.Member m ON gm.member_id = m.id
ORDER BY g.id;
```
> Der View `view_group_members` lädt alle Mitglieder und die zugehörigen Gruppen. Die Auflistung ist nach Gruppen-Id sortiert.

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_group_members?storage=gamification*

## Sent-Notifications
```sql
CREATE OR REPLACE VIEW view_sent_notifications AS
SELECT
    h.id AS history_id,
    n.id AS notification_id,
    n.title AS notification_title,
    n.body AS notification_body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.created_at AS notification_created_at,
    h.timestamp AS sent_at,
    t.id AS trigger_id,
    t.description AS trigger_description
FROM gamification.History h
JOIN gamification.Notifications n ON h.notification_id = n.id
LEFT JOIN gamification.Triggers t ON n.trigger_id = t.id
ORDER BY h.timestamp DESC;
```
> Der View `view_sent_notifications` zeigt alle gesendeten Nachrichten, sortiert nach `sent_at` Timestamp. 

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_sent_notifications?storage=gamification*

## Notification-Statistics
```sql
CREATE OR REPLACE VIEW view_notification_full_statistics AS
SELECT
    -- Notification-Ebene
    n.id AS notification_id,
    n.title AS notification_title,
    n.body AS notification_body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.created_at AS notification_created_at,
    n.trigger_id,
    
    -- History-Ebene
    h.id AS history_id,
    h.timestamp AS sent_at,

    -- Statistics-Ebene
    s.id AS statistic_id,
    s.created_at AS event_created_at,

    -- Event-Typ & Action
    et.id AS event_type_id,
    et.name AS event_type_name,
    a.id AS action_id,
    a.action_type,
    a.title AS action_title,
    a.icon AS action_icon

FROM gamification.Notifications n
JOIN gamification.History h
  ON h.notification_id = n.id
LEFT JOIN gamification.Statistics s
  ON s.history_id = h.id
LEFT JOIN gamification.Event_Types et
  ON s.event_type_id = et.id
LEFT JOIN gamification.Actions a
  ON s.action_id = a.id
ORDER BY h.timestamp DESC, s.created_at DESC;
```

> Dieser View hat das Ziel die Tabellen `History`, `Actions`, `Notifications` und `Statistics` aufzulösen. Hier empfiehlt es sich, die URL-Filterung nach einer **history_id** durchzuführen -> Statistiken zu einer gesendeten Nachricht.

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_notification_full_statistics?storage=gamification&filter=history_id,eq,2*

