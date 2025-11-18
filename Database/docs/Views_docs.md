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
### alle Trigger -renamed id-
```sql
CREATE OR REPLACE VIEW view_triggers AS 
SELECT
    t.id AS t_id,
    t.description,
    t.cron,
    t.time_once,
    t.last_triggered_at,
    t.active
FROM gamification.Triggers t;
```
> Der View `view_triggers` liefert alle Trigger zurück und benennt `id` zu `t_id` um.

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_triggers?storage=gamification*


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


## Notifications
```sql
CREATE OR REPLACE VIEW view_notifications_with_type AS
SELECT
    n.id AS notification_id,
    n.title,
    n.body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.created_at,
    t.id AS trigger_id,
    t.description AS trigger_description,
    CASE
        WHEN t.cron IS NULL AND t.time_once IS NULL THEN 'event'
        WHEN t.cron IS NULL AND t.time_once IS NOT NULL THEN 'once'
        WHEN t.cron IS NOT NULL AND t.time_once IS NULL THEN 'time'
        ELSE 'invalid'
    END AS type
FROM gamification.Notifications n
LEFT JOIN gamification.Triggers t
    ON n.trigger_id = t.id;
```
> Der View `view_notifications` zeigt alle Notifications an mit dem Zusatz `type` -> (`event`/`time`/`once`)

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_notifications_with_type?storage=gamification*


## Sent-Notifications
```sql
CREATE OR REPLACE VIEW view_sent_notifications AS
SELECT
    h.id AS history_id,
    n.notification_id,
    n.title AS notification_title,
    n.body AS notification_body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.type,

    DATE(n.created_at) AS notification_date,
    TO_CHAR(n.created_at, 'HH24:MI:SS') AS notification_time,
    DATE(h.timestamp) AS sent_date,
    TO_CHAR(h.timestamp, 'HH24:MI:SS') AS sent_time,

    t.id AS trigger_id,
    t.description AS trigger_description
FROM gamification.History h
JOIN gamification.view_notifications_with_type n ON h.notification_id = n.notification_id
LEFT JOIN gamification.Triggers t ON n.trigger_id = t.id
ORDER BY h.timestamp DESC;
```
> Der View `view_sent_notifications` zeigt alle gesendeten Nachrichten, sortiert nach `sent_at` Timestamp. das `created_at` und `sent_date` sind außerdem in Datum und Zeit.
> Außerdem wird hier der view `view_notifications_with_type` verwendet, zum direkten auflösen des Typs.

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_sent_notifications?storage=gamification*

## Notification-Statistics
```sql
CREATE OR REPLACE VIEW view_statistics_by_history AS
SELECT
    h.id AS history_id,

    json_agg(
        json_build_object(
            'action', action_name,
            'amount', event_count
        )
        ORDER BY action_name
    ) AS statistics
FROM (
    SELECT
        h.id AS history_id,

        CASE
            WHEN s.action_id IS NOT NULL THEN a.action_type
            ELSE et.name
        END AS action_name,

        COUNT(*) AS event_count
    FROM gamification.History h
    JOIN gamification.Statistics s
        ON s.history_id = h.id
    LEFT JOIN gamification.Actions a
        ON a.id = s.action_id
    LEFT JOIN gamification.Event_Types et
        ON et.id = s.event_type_id
    GROUP BY h.id, action_name
) grouped
JOIN gamification.History h ON grouped.history_id = h.id
GROUP BY h.id;
```
> Der View `view_statistics_by_history` gibt passend zu den history_ids die Anzahl an verschiedenen Aktionen (`click`, `swipes`, `actions`). Nutze den `&filter` zur Filterung nach einer bestimmten History-id.

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_statistics_by_history?storage=gamification&filter=history_id,eq,1*
