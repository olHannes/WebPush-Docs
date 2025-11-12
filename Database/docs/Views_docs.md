# Views Dokumentation
*Diese Datei beschreibt alle erstellten Views der Datenbank Smartmonitoring_airquality.gamification. Es soll außerdem als Hilfe bei der Entwicklung des Frontend's dienen*
> Jeder Eintrag hier sollte aus dem SQL-Script und einer dazugehörigen Beschreibung / Erklärung bestehen. Die URL beschreibt außerdem den SmartData Zugriff.


## Trigger
### Zeitbasierte Trigger
```sql
CREATE OR REPLACE VIEW view_triggers_with_schedule AS
SELECT
    id AS trigger_id,
    description,
    active,
    last_triggered_at,
    config,
    config->'when'->'schedule' AS schedule_config,
    config->'when'->'conditions' AS conditions_config
FROM gamification.Triggers
WHERE active = TRUE
  AND config->'when'->'schedule' IS NOT NULL;
```
> Der View `view_triggers_with_schedule` liefert alle Trigger, welche zeitbasiert arbeiten. *Die Datenbasierten conditions müssen vor dem Senden trotzdem geprüft werden.*

URL: *https://localhost:8181/SmartDataAirquality/smartdata/records/view_triggers_with_schedule?storage=gamification*


### Datenbasierte Trigger
```sql
CREATE OR REPLACE VIEW view_triggers_without_schedule AS
SELECT
    id AS trigger_id,
    description,
    active,
    last_triggered_at,
    config,
    config->'when'->'conditions' AS conditions_config
FROM gamification.Triggers
WHERE active = TRUE
  AND (
      config->'when' IS NULL
      OR config->'when'->'schedule' IS NULL
  );
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

